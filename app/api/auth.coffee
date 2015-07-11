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
      res.sendStatus 401
      return
    # Generate token and save...
    user.token = randtoken.generate 32
    db.collections.user.update user.id,
      token: user.token
    .populate 'groups'
    .then (users) ->
      userSerialized = user.toJSON()
      userSerialized.token = user.token
      res.json userSerialized
    .catch (err) ->
      res.sendStatus 500
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
    res.sendStatus 200

module.exports = router
