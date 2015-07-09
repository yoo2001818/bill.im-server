passport = require 'passport'
FacebookStrategy = require('passport-facebook').Strategy
FacebookTokenStrategy = require('passport-facebook-token').Strategy

debug = require 'debug'
log = debug 'app:passport'

db = require './db'
config = require './config'

log 'Loading passport'

oAuthVerifyLogin = (accessToken, refreshToken, profile, done) ->
  userTemplate = 
    name: 'Name unknown'
  if profile && profile.displayName
    userTemplate.name = profile.displayName
  log 'Finding passport information'
  db.collections.passport.findOrCreate
    identifier: profile.id
    type: 'oauth'
  ,
    accessToken: accessToken
    refreshToken: refreshToken
    identifier: profile.id
    type: 'oauth'
  .then (passportObj) ->
    if passportObj.user?
      log 'Found passport and user; Finding user' 
      return db.collections.user.findOne passportObj.user
      .populate 'groups'
    else
      userObj = null
      log 'Found passport and no user; Creating user'
      userTemplate.passport = passportObj.id
      return db.collections.user.create userTemplate
      .populate 'groups'
      .then (user) ->
        userObj = user
        log 'Applying user id into passport'
        return db.collections.passport.update passportObj.id,
          user: user.id
      .then () -> userObj
  .then (user) ->
    log 'Found user. Done!'
    done null, user
  .catch (error) ->
    done error, false,
      message: 'Internal server error'
  .done()

log 'Registering Facebook strategy'
passport.use new FacebookStrategy config.auth.facebook, oAuthVerifyLogin
passport.use new FacebookTokenStrategy config.auth.facebook, oAuthVerifyLogin

module.exports = passport
