express = require 'express'
app = express()

app.listen 8000, () ->
  throw err if err?
  console.log "Listening at port #{8000}"
