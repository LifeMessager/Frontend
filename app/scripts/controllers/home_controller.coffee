angular.module('app.controllers')

.controller('HomeController', [
  '$scope', '$dialog', '$i18next', 'errorAlert', 'Session', 'User'
  ($scope ,  $dialog ,  $i18next ,  errorAlert ,  Session ,  User) ->
    isEmailNotExist = (resp) ->
      return false if resp.status isnt 422
      _(resp.data.errors).chain().first().pick('field', 'code')
        .isEqual(field: 'email', code: 'missing').value()

    $scope.message = null

    $scope.login = ->
      $scope.loginPromise = Session.$create(email: $scope.email).catch (resp) ->
        return errorAlert() resp unless isEmailNotExist resp
        User.create(email: $scope.email).$promise.catch (resp) ->
          delete $scope.loginPromise
          if resp.status is 403
            $i18next "copy:home.errors.#{resp.data.message}"
          else
            errorAlert() resp
      .then (data) ->
        if _(data).trim()
          message = data
        else
          message = $i18next 'copy:home.login_mail_send_success'
        $scope.message = message

])
