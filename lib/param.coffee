module.exports = (req, key) ->
  return req.query[key] if req.query[key]?
  return req.body[key] if req.body[key]?
  return null
