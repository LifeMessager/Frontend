'use strict'

### Controllers ###

angular.module('app.controllers', [
  'ng-extra'
  'jm.i18next'
  'ui.bootstrap'
  'app.models'
])

.controller('HomeCtrl', [
  '$scope', '$dialog', 'errorAlert', 'Session', 'User'
  ($scope ,  $dialog ,  errorAlert ,  Session ,  User) ->
    isEmailNotExist = (resp) ->
      return false if resp.status isnt 422
      _(resp.data.errors).chain().first().pick('field', 'code')
        .isEqual(field: 'email', code: 'missing').value()

    $scope.logged = false
    $scope.login = ->
      $scope.loginPromise = Session.$create(email: $scope.email).catch (resp) ->
        return errorAlert() resp unless isEmailNotExist resp
        User.create(email: $scope.email).$promise
      .catch(errorAlert())
      .then ->
        $scope.logged = true
        return
])

.controller('LoginCtrl', [
  '$scope', '$http', '$state', '$stateParams', 'Session', 'User'
  ($scope ,  $http ,  $state ,  $stateParams ,  Session ,  User) ->
    {token} = $stateParams
    $state.go 'home' unless token
    session = new Session {token}
    User.get()
])
