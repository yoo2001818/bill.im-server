Q = require 'q'
express = require 'express'

db = require '../../lib/db'
auth = require '../../lib/auth'
param = require '../../lib/param'

router = express.Router()

router.all '/self/list', auth.loginRequired, (req, res, next) ->
  res.json
    code: 200
    groups: req.user.groups || []

router.all '/self/create', auth.loginRequired, (req, res, next) ->
  if not param(req, 'name')?
    return res.json
      code: 400
  # Currently this doesn't check conflicts, but whatever. Fair enough
  req.user.groups.add
    name: param req, 'name'
    description: param req, 'description'
  req.user.save (err, user) ->
    res.json
      code: 200
      group: user.groups[user.groups.length-1].toJSON()
      groups: user.groups

router.all '/self/join', auth.loginRequired, (req, res, next) ->
  id = parseInt param(req, 'id')
  if isNaN id
    res.status 400
    return res.json
      code: 400
  db.collections.group.findOne id
  .then (group) ->
    if not group?
      res.status 404
      return res.json
        code: 404
    for currentGroup in req.user.groups
      # If user already have that group
      if currentGroup.id == group.id
        res.status 422
        return res.json
          code: 422
          group: group
    req.user.groups.add group.id
    req.user.save (err, user) ->
      res.json
        code: 200
        group: group.toJSON()
        groups: user.groups
    return
  .catch (e) ->
    next e

router.all '/self/part', auth.loginRequired, (req, res, next) ->
  id = parseInt param(req, 'id')
  if isNaN id
    res.status 400
    return res.json
      code: 400
  db.collections.group.findOne id
  .then (group) ->
    if not group?
      res.status 404
      return res.json
        code: 404
    for currentGroup in req.user.groups
      if currentGroup.id == group.id
        req.user.groups.remove group.id
        req.user.save (err, user) ->
          res.json
            code: 200
            group: group.toJSON()
            groups: user.groups
        return
    res.status 422
    return res.json
      code: 422
      group: group
  .catch (e) ->
    next e

router.all '/list', (req, res, next) ->
  db.collections.group.find()
  .then (groups) ->
    result = groups.map (group) ->
      return group.toJSON()
    res.json
      code: 200
      groups: result
  .catch (e) ->
    next e

router.all '/search', (req, res, next) ->
  if not param(req, 'name')?
    return res.json
      code: 400
  db.collections.group.find
    name:
      contains: param(req, 'name')
  .then (groups) ->
    result = groups.map (group) ->
      return group.toJSON()
    res.json
      code: 200
      name: req.query.name
      groups: result
  .catch (e) ->
    next e

router.all '/info', (req, res, next) ->
  id = parseInt param(req, 'id')
  if isNaN id
    res.status 400
    return res.json
      code: 400
  db.collections.group.findOne id
  .populate 'users'
  .then (group) ->
    if not group?
      res.status 404
      return res.json
        code: 404
    result = null
    result = group.toJSON() if group?
    res.json
      code: 200
      group: result
  .catch (e) ->
    next e

module.exports = router
