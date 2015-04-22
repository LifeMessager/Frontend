angular.module('app.controllers')

.controller('LoginController', [
  '$scope', '$http', '$state', '$stateParams', '$cookies', '$q', '$dialog', '$moment', 'Session', 'User'
  ($scope ,  $http ,  $state ,  $stateParams ,  $cookies ,  $q ,  $dialog ,  $moment ,  Session ,  User) ->
    cookieExpiredAt = $moment().add(15, 'days').toDate()

    getSession = ->
      {token} = $stateParams
      $state.go 'home' unless token
      Session.save token

    gotoMainPage = ->
      $scope.loading = true
      User.get().$promise.then ->
        $state.go 'diary'

    $scope.needConfirmKeepSession = ->
      not $cookies.getObject('keepSession')?

    $scope.keepSession = ->
      $cookies.putObject 'keepSession', true, expires: cookieExpiredAt
      $scope.loading = true
      session.$renew().then gotoMainPage

    $scope.doNotKeepSession = ->
      $cookies.putObject 'keepSession', false, expires: cookieExpiredAt
      gotoMainPage()

    session = getSession()
    unless $scope.needConfirmKeepSession()
      gotoMainPage()
])
