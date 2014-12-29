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

    $urlRouterProvider.otherwise '/diaries/'

    $stateProvider
      .state('home', {
        url: '/'
        templateUrl: 'partials/home.html'
        controller: 'HomeController'
      })
      .state('login', {
        url: '/login?token'
        templateUrl: 'partials/login.html'
        controller: 'LoginController'
      })
      .state('diary', {
        url: '/diaries/{date:[\\d-]{4}-[\\d-]{2}-[\\d-]{2}}'
        templateUrl: 'partials/diary.html'
        controller: 'DiaryController'
        params:
          date:
            squash: true
            value: -> moment().format 'YYYY-MM-DD'
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
