passport = require 'passport'
FacebookStrategy = require('passport-facebook').Strategy
FacebookTokenStrategy = require('passport-facebook-token').Strategy

debug = require 'debug'
log = debug 'app:passport'

config = require './config'

log 'Loading passport'

oAuthVerifyLogin = (accessToken, refreshToken, profile, done) ->
  log accessToken
  log refreshToken
  log profile
  done null, false,
    message: 'Not implemented yet'

log 'Registering Facebook strategy'
passport.use new FacebookStrategy config.auth.facebook, oAuthVerifyLogin
passport.use new FacebookTokenStrategy config.auth.facebook, oAuthVerifyLogin

module.exports = passport
