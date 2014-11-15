
angular.module('app.models')

.factory('User', [
  '$resource', '$http'
  ($resource ,  $http) ->
    User = $resource(
      '/users/:id'
      {id: '@id'}
    )

    User
])
