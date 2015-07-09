passport = require '.passport'
db = require './db'

loginRequired = (req, res, next) ->
  passport.authenticate('localapikey', (err, user, info) ->
    return next err if err
    if !user
      res.status 401
      res.json
        code: 401
        info: info
      return
    req.user = user
    next()
  )(req, res, next)

module.exports =
  loginRequired: loginRequired
