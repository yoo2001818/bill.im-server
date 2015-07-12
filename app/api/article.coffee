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
  db.collections.article.find query # Populate users?
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
  .then (article) ->
    if not article?
      return res.sendStatus 404
    result = null
    result = article.toJSON() if group?
    res.json result
  .catch (e) ->
    next e

module.exports = router
