
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
    )

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

    User
])
