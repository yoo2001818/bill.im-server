passport = require './passport'
db = require './db'

loginRequired = (req, res, next) ->
  passport.authenticate('localapikey', (err, user, info) ->
    return next err if err
    if !user
      res.sendStatus 401
      return
    req.user = user
    next()
  )(req, res, next)

module.exports =
  loginRequired: loginRequired
