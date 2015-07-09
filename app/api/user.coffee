Q = require 'q'
express = require 'express'

db = require '../../lib/db'
auth = require '../../lib/auth'

router = express.Router()

router.all '/self/info', auth.loginRequired, (req, res, next) ->
  res.json
    code: 200
    user: req.user.toJSON()

module.exports = router
