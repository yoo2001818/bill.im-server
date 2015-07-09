express = require 'express'
passport = require '../lib/passport'

router = express.Router()

router.all '/facebook/token', passport.authenticate 'facebook-token'
router.get '/facebook', passport.authenticate 'facebook'
router.get '/facebook/callback', passport.authenticate 'facebook'

module.exports = router
