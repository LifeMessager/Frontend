angular.module('app.controllers')

.controller('UserDeletedController', [
  '$scope', '$moment', '$state', 'User', 'errorAlert'
  ($scope ,  $moment ,  $state ,  User ,  errorAlert) ->
    $scope.mark_delete_time = ->
      return '...' unless $scope.user.deleted_at
      $moment($scope.user.deleted_at).format 'YYYY-MM-DD HH:mm'

    $scope.really_delete_time = ->
      return '...' unless $scope.user.deleted_at
      $moment($scope.user.deleted_at).add(7, 'days').format 'YYYY-MM-DD HH:mm'

    $scope.recover = ->
      $scope.user.$recover().catch(errorAlert()).then (resp) ->
        $scope.user.deleted_at = null
        $state.go 'diary'

    $scope.user = User.get()

    $scope.user.$promise.then (user) ->
      return if user.destroyed()
      $state.go 'diary'
])
