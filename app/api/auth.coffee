Q = require 'q'
express = require 'express'
randtoken = require 'rand-token'

passport = require '../../lib/passport'
auth = require '../../lib/auth'
db = require '../../lib/db'

handleLogin = (method, req, res, next) ->
  passport.authenticate(method, (err, user, info) ->
    return next err if err
    if !user
      res.status 401
      res.json
        code: 401
        info: info
      return
    # Generate token and save...
    user.token = randtoken.generate 32
    db.collections.user.update user.id,
      token: user.token
    .populate 'groups'
    .then (users) ->
      user = users[0]
      res.json
        code: 200
        token: user.token
        user: user.toJSON()
        'new': user.groups.length == 0
    .catch (err) ->
      res.status 500
      res.json
        code: 500
    .done()
  )(req, res, next)

router = express.Router()

router.all '/facebook/token', handleLogin.bind null, 'facebook-token'
router.get '/facebook', handleLogin.bind null, 'facebook'
router.get '/facebook/callback', handleLogin.bind null, 'facebook'

router.all '/logout', auth.loginRequired, (req, res, next) ->
  req.user.token = null
  req.user.save (err) ->
    return next err if err
    res.json
      code: 200

module.exports = router
