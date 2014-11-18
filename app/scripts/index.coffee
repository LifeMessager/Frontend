'use strict'

angular.module('app', [
  'ui.router'
  'ngAria'

  'app.controllers'
  'app.directives'
  'app.services'
  'app.filters'
  'app.models'
])

.config([
  '$locationProvider', '$stateProvider', '$urlRouterProvider'
  ($locationProvider ,  $stateProvider ,  $urlRouterProvider) ->
    $locationProvider.html5Mode(enabled: false).hashPrefix("!")

    $urlRouterProvider.otherwise '/'

    $stateProvider
      .state('home', {
        url: '/'
        templateUrl: 'partials/home.html'
        controller: 'HomeCtrl'
      })
      .state('login', {
        url: '/login?token'
        templateUrl: 'partials/login.html'
        controller: 'LoginCtrl'
      })
])

.run([
  '$window', '$state', 'Session'
  ($window ,  $state ,  Session) ->
    $window._appLogout = ->
      Session.clean()
      $state.go 'home'
])

angular.element(document).ready ->
  angular.bootstrap(document, ['app'])
