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
      passport:
        model: 'passport'
      give:
        type: 'integer'
        required: true
        defaultsTo: 0
      take:
        type: 'integer'
        required: true
        defaultsTo: 0
      exchange:
        type: 'integer'
        required: true
        defaultsTo: 0
      toJSON: () ->
        obj = @toObject()
        delete obj.passport
        delete obj.token
        return obj
  Passport: Waterline.Collection.extend
    identity: 'passport'
    connection: 'default'
    attributes:
      user:
        model: 'user'
      type:
        type: 'string'
        required: true
      identifier: 'string'
      accessToken: 'string'
      refreshToken: 'string'
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
        type: 'integer'
        required: true
        in: [0, 1] # 빌려주세요, 교환해요
      category:
        type: 'integer'
        required: true
      state:
        type: 'integer'
        required: true
        in: [0, 1, 2, 3, 4] # 대기 중, 삭제 됨, 승인, 빌려줌, 완료
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
      responder:
        model: 'user'
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
