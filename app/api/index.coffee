express = require 'express'
router = express.Router()

router.use '/auth', require './auth'
router.use '/user', require './user'
router.use '/group', require './group'

module.exports = router
