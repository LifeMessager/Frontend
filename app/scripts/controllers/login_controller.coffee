angular.module('app.controllers')

.controller('LoginController', [
  '$scope', '$http', '$state', '$stateParams', 'Session', 'User'
  ($scope ,  $http ,  $state ,  $stateParams ,  Session ,  User) ->
    {token} = $stateParams
    $state.go 'home' unless token
    session = new Session {token}
    User.get().$promise.then ->
      $state.go 'diary'
])
