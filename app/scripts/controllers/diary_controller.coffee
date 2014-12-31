angular.module('app.controllers')

.controller('DiaryController', [
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
        controller: 'SettingsController'
      )

    $scope.newNote = ->
      $modal.open(
        templateUrl: 'partials/diary/new_note.html'
        controller: 'DiaryController.NewNoteController'
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

.controller('DiaryController.NewNoteController', [
  '$scope', 'Note'
  ($scope ,  Note) ->
    $scope.submit = ->
      return unless $scope.content
      Note.create(content: $scope.content).$promise.then $scope.$close
])
