express = require 'express'

db = require './lib/db'

app = express()

db.init().then () ->
  app.listen 8000, () ->
    throw err if err?
    console.log "Listening at port #{8000}"
.done()
