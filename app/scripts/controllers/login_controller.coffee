angular.module('app.controllers')

.controller('LoginController', [
  '$scope', '$http', '$state', '$stateParams', '$cookies', '$q', '$dialog', '$moment', 'Session', 'User'
  ($scope ,  $http ,  $state ,  $stateParams ,  $cookies ,  $q ,  $dialog ,  $moment ,  Session ,  User) ->
    cookieExpiredAt = $moment().add(15, 'days').toDate()

    getSession = ->
      {token} = $stateParams
      $state.go 'home' unless token
      new Session {token}

    gotoMainPage = ->
      $scope.loading = true
      User.get().$promise.then ->
        $state.go 'diary'

    $scope.renew = ->
      $scope.loading = true
      session.$renew().then gotoMainPage

    $scope.needConfirmKeepSession = ->
      not $cookies.getObject('keepSession')

    $scope.keepSession = ->
      $cookies.putObject 'keepSession', true, expires: cookieExpiredAt
      $scope.renew()

    $scope.doNotKeepSession = ->
      $cookies.putObject 'keepSession', false, expires: cookieExpiredAt
      gotoMainPage()

    session = getSession()
    keepSession = $cookies.getObject('keepSession')
    return if not keepSession?
    if keepSession
      if Session.exist() then gotoMainPage() else $scope.renew()
    else
      gotoMainPage()
])
