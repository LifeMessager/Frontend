'use strict'

angular.module('app', [
  'ui.router'
  'ngRaven'
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
      .state('changeEmail', {
        url: '/user/email/edit?token'
        templateUrl: 'partials/change_email.html'
        controller: 'ChangeEmailController'
      })
      .state('diary', {
        url: '/diaries/{date:date}'
        templateUrl: 'partials/diary.html'
        controller: 'DiaryController'
        params:
          date:
            squash: true
            value: -> moment().toDate()
      })
      .state('deleted', {
        url: '/user_deleted'
        templateUrl: 'partials/user_deleted.html'
        controller: 'UserDeletedController'
      })
])

.run([ # raven-js
  '$raven', '$rootScope'
  ($raven ,  $rootScope) ->
    $rootScope.$on 'model:user:login', (user) ->
      $raven.setUser id: user.id, email: user.email
])

.run([ # 自动设置 html 元素的 class 属性
  '$rootScope', '$state'
  ($rootScope ,  $state) ->
    $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      $htmlElem = angular.element 'html'
      isClassnameCreatedBySelf = (classname) -> /^page-/.test classname
      oldClassnames = ($htmlElem.attr('class') ? '').split(' ').filter(isClassnameCreatedBySelf).join ' '
      $htmlElem.removeClass(oldClassnames)

      nestedStates = toState.name.split('.')
      _.range(nestedStates.length).forEach (index) ->
        (states = nestedStates.slice 0, index + 1).unshift 'page'
        $htmlElem.addClass states.join '-'
])

.run([
  '$moment'
  ($moment) ->
    $moment.locale 'zh-cn'
])

.run([
  '$window', '$state', 'Session'
  ($window ,  $state ,  Session) ->
    $window._appLogout = ->
      Session.clean()
      $state.go 'home'
])

Raven.config('{%= RAVEN_DSN %}', {}).install()

angular.element(document).ready ->
  angular.bootstrap(document, ['app'])
