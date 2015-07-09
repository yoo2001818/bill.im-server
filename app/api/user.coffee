Q = require 'q'
express = require 'express'

db = require '../../lib/db'
auth = require '../../lib/auth'

router = express.Router()

router.all '/self/info', auth.loginRequired, (req, res, next) ->
  res.json
    code: 200
    user: req.user.toJSON()

router.all '/self/delete', auth.loginRequired, (req, res, next) ->
  # Delete passport associated with the user
  db.collections.passport.destroy req.user.passport
  .then () ->
    db.collections.user.destroy req.user.id
  .then () ->
    res.json
      code: 200
  .catch (e) ->
    next e

router.all '/self/set', auth.loginRequired, (req, res, next) ->
  req.user.name = req.query.name
  req.user.phone = req.query.phone
  req.user.description = req.query.description
  req.user.save (err) ->
    return next err if err
    res.json
      code: 200
      user: req.user.toJSON()

router.all '/info', (req, res, next) ->
  id = parseInt req.query.id
  if isNaN id
    res.status 400
    return res.json
      code: 400
  db.collections.user.findOne id
  .populate 'groups'
  .then (user) ->
    if not user?
      res.status 404
      return res.json
        code: 404
    result = null
    result = user.toJSON() if user?
    res.json
      code: 200
      user: result
  .catch (e) ->
    next e

# TODO this is debug feature, it should be remove ASAP!!!!

router.all '/list', (req, res, next) ->
  db.collections.user.find()
  .populate 'groups'
  .then (users) ->
    result = users.map (user) ->
      return user.toJSON()
    res.json
      code: 200
      users: result
  .catch (e) ->
    next e

module.exports = router
