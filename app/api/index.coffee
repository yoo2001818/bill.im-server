express = require 'express'
router = express.Router()

router.use '/auth', require './auth'
router.use '/user', require './user'
router.use '/group', require './group'
router.use '/article', require './article'

module.exports = router
