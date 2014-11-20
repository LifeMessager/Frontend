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
    User.get().$promise.then ->
      $state.go 'diary'
])

.controller('DiaryCtrl', [
  '$scope', '$stateParams', '$moment', '$q', 'Diary'
  ($scope ,  $stateParams ,  $moment ,  $q ,  Diary) ->
    refreshDateRef = ->
      $scope.previousDate = $moment($scope.date).subtract(1, 'd').format 'YYYY-MM-DD'
      $scope.nextDate = $moment($scope.date).add(1, 'd').format 'YYYY-MM-DD'
      $scope.nextDate = null if $moment($scope.nextDate).isAfter $moment()

    refreshDiaryData = ->
      $scope.diaryStatus = 'loading'
      Diary.get(date: $scope.date).$promise.then (diary) ->
        $scope.diaryStatus = 'loaded'
        $scope.diary = diary
        diary
      .catch (resp) ->
        $scope.diaryStatus = if resp.status is 404 then 'notExist' else 'failed'
        $q.reject resp

    $scope.date = $stateParams.date

    # 可选值 loading, loaded, failed, notExist
    $scope.diaryStatus = 'loading'

    $scope.$watch 'date', (date) ->
      refreshDateRef()
      refreshDiaryData()

])
