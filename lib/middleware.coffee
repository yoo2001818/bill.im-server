Q = require 'q'
debug = require 'debug'
log = debug 'app:middleware'

passport = require './passport'
morgan = require 'morgan'
bodyParser = require 'body-parser'
serveStatic = require 'serve-static'

module.exports = (app) ->
  Q.fcall () ->
    log 'Registering middlewares'
    app.use morgan 'dev'
    app.use serveStatic process.cwd() + '/public'
    app.use bodyParser.urlencoded
      extended: false
    # JSON is not required, right?
    app.use passport.initialize()
