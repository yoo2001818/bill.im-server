Waterline = require 'waterline'
module.exports = 
  User: Waterline.Collection.extend
    identity: 'user'
    connection: 'default'
    attributes:
      name:
        type: 'string'
        required: true
      phone: 'string'
      description: 'string'
      groups: 
        collection: 'group'
        via: 'users'
        dominant: true
      enabled:
        type: 'boolean'
        required: true
        defaultsTo: true
      token: 'string'
      auth: 'json' # Should be changed..
  Group: Waterline.Collection.extend
    identity: 'group'
    connection: 'default'
    attributes:
      name:
        type: 'string'
        required: true
      description: 'string'
      users:
        collection: 'user'
        via: 'groups'
  Article: Waterline.Collection.extend
    identity: 'article'
    connection: 'default'
    attributes:
      group:
        model: 'group'
        required: true
      type:
        type: 'int'
        required: true
        in: [0, 1] # 빌려주세요, 교환해요
      state:
        type: 'int'
        required: true
        in: [0, 1, 2] # 대기 중, 거래 완료, 삭제됨
        defaultsTo: 0
      name:
        type: 'string'
        required: true
      description: 'string'
      reward: 'string'
      location: 'string'
      author:
        model: 'user'
        required: true
      transaction:
        model: 'transaction'
  Comment: Waterline.Collection.extend
    identity: 'comment'
    connection: 'default'
    attributes:
      description:
        type: 'string'
        required: true
      author:
        model: 'user'
        required: true
      secret:
        type: 'boolean'
        required: true
        defaultsTo: false
      article:
        model: 'article'
        required: true
      reply:
        model: 'user'
      transaction:
        model: 'transaction'
  Transaction: Waterline.Collection.extend
    identity: 'transaction'
    connection: 'default'
    attributes:
      requester:
        model: 'user'
        required: true
      responder:
        model: 'user'
        required: true
      article:
        model: 'article'
        required: true
      state:
        type: 'int'
        in: [0, 1, 2, 3, 4, 5] # 대기, 거절, 삭제, 승인, 빌려줌, 완료
        required: true
        defaultsTo: 0
      reward:
        type: 'string'
        required: true
      location:
        type: 'string'
        required: true
