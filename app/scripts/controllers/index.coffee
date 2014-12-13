'use strict'

### Controllers ###

angular.module('app.controllers', [
  'ng-extra'
  'jm.i18next'
  'ui.bootstrap'
  'monospaced.elastic'
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
  '$scope', '$stateParams', '$state', '$moment', '$q', '$modal', 'Session', 'Diary'
  ($scope ,  $stateParams ,  $state ,  $moment ,  $q ,  $modal ,  Session ,  Diary) ->
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

    $scope.logout = ->
      Session.clean()
      $state.go 'home'

    $scope.showSettings = ->
      $modal.open(
        templateUrl: 'partials/diary/settings.html'
        controller: 'SettingsCtrl'
      )

    $scope.newNote = ->
      $modal.open(
        templateUrl: 'partials/diary/new_note.html'
        controller: 'NotesCtrl.NewCtrl'
      ).result.then (note) ->
        if _($scope.diary?.notes).isArray()
          $scope.diary.notes.push note
        else
          refreshDiaryData()
        note

    $scope.date = $stateParams.date

    # 可选值 loading, loaded, failed, notExist
    $scope.diaryStatus = 'loading'

    $scope.$watch 'date', (date) ->
      refreshDateRef()
      refreshDiaryData()

])

.controller('SettingsCtrl', [
  '$scope', '$q', '$moment', '$jstz', 'User', 'errorAlert'
  ($scope ,  $q ,  $moment ,  $jstz ,  User ,  errorAlert) ->
    userConfig = (user) ->
      _.pick user, 'timezone', 'alert_time'

    formatTimezoneOffset = (name, properties) ->
      offset = parseInt _(properties.split ',').first(), 10
      prefix = if offset is 0 then '' else if offset > 0 then '+' else '-'
      time = $moment.utc(Math.abs(offset) * 60 * 1000).format 'HH:mm'
      displayName: "#{name} (#{prefix}#{time})", name: name

    $scope.submit = ->
      return if $scope.settingForm.$invalid

      if user.subscribed is $scope.userSnapshot.subscribed
        subPromise = $q.when()
      else
        subscribeMethod = if $scope.userSnapshot.subscribed then 'subscribe' else 'unsubscribe'
        subPromise = user["$#{subscribeMethod}"]()

      patch = userConfig $scope.userSnapshot
      if angular.equals patch, userConfig(user)
        updatePromise = $q.when()
      else
        updatePromise = user.$update null, patch

      $q.all([subPromise, updatePromise]).catch(errorAlert()).then $scope.$close

    user = User.getCurrentUser()
    $scope.userSnapshot = null
    $scope.avaliableAlertTimes = _.range(0, 24).map (hour) -> "#{if hour < 10 then "0" else ""}#{hour}:00"
    $scope.avaliableTimezones = _.map $jstz.olson.timezones, formatTimezoneOffset

    user.$promise.then (user) ->
      $scope.userSnapshot = angular.clean user
])

.controller('NotesCtrl.NewCtrl', [
  '$scope', 'Note'
  ($scope ,  Note) ->
    $scope.submit = ->
      return unless $scope.content
      Note.create(content: $scope.content).$promise.then $scope.$close
])
