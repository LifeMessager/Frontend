angular.module('app.controllers')

.controller('ChangeEmailController', [
  '$scope', '$state', '$stateParams', 'User', 'Session'
  ($scope ,  $state ,  $stateParams ,  User ,  Session) ->
    gotoMainPage = ->
      $state.go 'diary'

    $scope.loading = true

    token = $stateParams.token

    if _.isEmpty Session.restore()
      Session.save token

    User.get().$promise.then (user) ->
      user.$changeEmail {token}
    .then ->
      setTimeout gotoMainPage, 5 * 1000
    .catch (err) ->
      console.log err
      $scope.failed = true
    .finally ->
      $scope.loading = false
])
