Waterline = require 'waterline'
module.exports = 
  User: Waterline.Collection.extend
    identity: 'user'
    connection: 'default'
    attributes:
      name: 'string'
