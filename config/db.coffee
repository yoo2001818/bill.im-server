# Bill.im uses Waterline for its database - if you have questions about this
# config file, please refer to https://github.com/balderdashy/waterline
module.exports = 
  adapters:
    default: require 'sails-memory'
    memory: require 'sails-memory'
  connections:
    default:
      adapter: 'memory'
  defaults:
    migrate: 'alter'
