# Bill.im uses Waterline for its database - if you have questions about this
# config file, please refer to https://github.com/balderdashy/waterline
module.exports = 
  adapters:
    default: require 'sails-disk'
    memory: require 'sails-memory'
    disk: require 'sails-disk'
  connections:
    default:
      adapter: 'disk'
  defaults:
    migrate: 'alter'
