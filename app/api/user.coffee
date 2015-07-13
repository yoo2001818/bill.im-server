Q = require 'q'
express = require 'express'

db = require '../../lib/db'
auth = require '../../lib/auth'
param = require '../../lib/param'

router = express.Router()

router.all '/self/info', auth.loginRequired, (req, res, next) ->
  res.json req.user.toJSON()

router.all '/self/delete', auth.loginRequired, (req, res, next) ->
  # Delete passport associated with the user
  db.collections.passport.destroy req.user.passport
  .then () ->
    db.collections.user.update req.user.id
      enabled: false
      token: null
  .then () ->
    res.sendStatus 200
  .catch (e) ->
    next e

router.all '/self/set', auth.loginRequired, (req, res, next) ->
  req.user.name = param req, 'name'
  req.user.phone = param req, 'phone'
  req.user.description = param req, 'description'
  req.user.save (err) ->
    return next err if err
    res.json req.user.toJSON()

router.all '/self/gcm', auth.loginRequired, (req, res, next) ->
  req.user.gcm = param req, 'gcm'
  req.user.save (err) ->
    return next err if err
    res.sendStatus 200

router.all '/info', (req, res, next) ->
  id = parseInt param(req, 'id')
  if isNaN id
    return res.sendStatus 400
  db.collections.user.findOne id
  .populate 'groups'
  .then (user) ->
    if not user?
      return res.sendStatus 404
    result = null
    result = user.toJSON() if user?
    res.json result
  .catch (e) ->
    next e

# TODO this is debug feature, it should be remove ASAP!!!!

router.all '/list', (req, res, next) ->
  db.collections.user.find()
  .populate 'groups'
  .then (users) ->
    result = users.map (user) ->
      return user.toJSON()
    res.json result
  .catch (e) ->
    next e

module.exports = router
