Q = require 'q'
express = require 'express'

db = require '../../lib/db'
auth = require '../../lib/auth'
param = require '../../lib/param'

router = express.Router()

router.all '/list', (req, res, next) ->
  group = param req, 'group'
  category = param req, 'category', null
  type = param req, 'type', null
  state = param req, 'state', 0
  amount = param req, 'amount', 20
  start = param req, 'start', 2<<30 # OK, this is definitely not the best way
  name = param req, 'name', ''
  return res.sendStatus 400 if not group?
  # Build criteria
  where =
    group: group
  where.category = category if category?
  where.type = type if type?
  where.name =
    contains: name
  where.state = state if state?
  where.id =
    '<': start

  query =
    where: where
    sort: 'id DESC'
  query.limit = amount if amount?
  db.collections.article.find query
  .populate 'author'
  .populate 'responder' # Don't populate comments - it's not likely to be used
  .then (articles) ->
    result = articles.map (article) ->
      return article.toJSON()
    res.json result
  .catch (e) ->
    next e

router.all '/info', (req, res, next) ->
  id = parseInt param(req, 'id')
  if isNaN id
    return res.sendStatus 400
  db.collections.article.findOne id
  .populate 'author'
  .populate 'responder'
  .populate 'comments'
  .then (article) ->
    if not article?
      return res.sendStatus 404
    result = null
    result = article.toJSON() if article?
    res.json result
  .catch (e) ->
    next e

router.all '/self/create', auth.loginRequired, (req, res, next) ->
  template =
    group: param req, 'group'
    category: param req, 'category'
    type: param req, 'type'
    name: param req, 'name'
    description: param req, 'description'
    reward: param req, 'reward'
    location: param req, 'location'
    author: req.user.id
  db.collections.article.create template
  .then (article) ->
    res.json article.toJSON()
  .catch (e) ->
    res.sendStatus 400

router.all '/self/modify', auth.loginRequired, (req, res, next) ->
  id = param req, 'id'
  author = req.user.id
  query =
    id: id
    author: author
    state: 0
  template =
    category: param req, 'category'
    type: param req, 'type'
    name: param req, 'name'
    description: param req, 'description'
    reward: param req, 'reward'
    location: param req, 'location'
  db.collections.article.update query, template
  .then (articles) ->
    return res.sendStatus 422 if articles.length == 0
    res.json articles[0].toJSON()
  .catch (e) ->
    res.sendStatus 400

router.all '/self/delete', auth.loginRequired, (req, res, next) ->
  id = param req, 'id'
  author = req.user.id
  query =
    id: id
    author: author
    state: 0
  db.collections.article.destroy query
  .then () ->
    res.sendStatus 200
  .catch (e) ->
    res.sendStatus 400

router.all '/self/list', auth.loginRequired, (req, res, next) ->
  group = param req, 'group'
  user = req.user.id
  return res.sendStatus 400 if not group?
  # Build criteria
  where =
    group: group
    or: [
      author: user
    ,
      responder: user
    ]
  query =
    where: where
    sort: 'id DESC'
  db.collections.article.find query
  .populate 'author'
  .populate 'responder' # Don't populate comments - it's not likely to be used
  .then (articles) ->
    result = articles.map (article) ->
      return article.toJSON()
    res.json result
  .catch (e) ->
    next e

module.exports = router
