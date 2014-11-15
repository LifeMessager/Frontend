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

    $scope.login = ->
      $scope.loginPromise = Session.$create(email: $scope.email).catch (resp) ->
        return errorAlert() resp unless isEmailNotExist resp
        User.create(email: $scope.email).$promise
      .catch(errorAlert())
      .then ->
        $dialog.alert(message: 'copy:home.login_mail_send_success')
        return
])
