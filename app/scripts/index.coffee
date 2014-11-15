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
    $locationProvider.html5Mode(false).hashPrefix("!")

    $urlRouterProvider.otherwise '/'

    $stateProvider
      .state('home', {
        url: '/'
        templateUrl: 'partials/home.html'
        controller: 'HomeCtrl'
      })
      .state('home.login', {
        url: '/login?token'
        templateUrl: 'partials/home.html'
        controller: 'HomeCtrl.LoginCtrl'
      })
])

angular.element(document).ready ->
  angular.bootstrap(document, ['app'])
