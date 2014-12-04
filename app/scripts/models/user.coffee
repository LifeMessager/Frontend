
angular.module('app.models')

.factory('User', [
  '$resource', '$http', 'argsHolder'
  ($resource ,  $http ,  argsHolder) ->
    User = $resource(
      '/users/:id'
      {id: '@id'}
      getCurrentUser:
        url: '/user'
        method: 'get'
      update:
        method: 'patch'
        normalize: true
      subscribe:
        url: '/users/:id/subscription'
        method: 'put'
        normalize: true
      unsubscribe:
        url: '/users/:id/subscription'
        method: 'delete'
        headers:
          Authorization: -> "unsubscribe #{User.getCurrentUser().unsubscribe_token}"
    )

    User.languages = [
      'zh-Hans-CN'
      'zh-Hant-TW'
      'en'
    ]

    User.wrapStaticMethod 'get', (fn) ->
      argsHolder 'params', (params = {}, success, error) ->
        cb = if params.id? then fn else User.getCurrentUser
        cb.apply this, arguments

    User.wrapStaticMethod 'getCurrentUser', (fn) ->
      cache = null
      argsHolder 'params', (params = {}, success, error) ->
        unless _(params).isEmpty()
          return fn.apply this, arguments
        return cache if cache
        user = fn.apply this, arguments
        user.$promise.then -> cache = user
        user

    User.wrapInstanceMethod 'subscribe', (fn) ->
      argsHolder 'params-data', (params, data, success, error) ->
        fn.apply(this, arguments).then (resp) =>
          @subscribed = true
          resp

    User.wrapInstanceMethod 'unsubscribe', (fn) ->
      argsHolder 'params', (params, success, error) ->
        fn.apply(this, arguments).then (resp) =>
          @subscribed = false
          resp

    User
])
