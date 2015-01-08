angular.module('app.controllers')

.controller('DiaryController', [
  '$scope', '$stateParams', '$state', '$moment', '$q', '$modal', '$scrollTo', 'Session', 'User', 'Diary', 'Note'
  ($scope ,  $stateParams ,  $state ,  $moment ,  $q ,  $modal ,  $scrollTo ,  Session ,  User ,  Diary ,  Note) ->
    refreshDateRef = ->
      $scope.previousDate = $moment($scope.date).subtract(1, 'd').format 'YYYY-MM-DD'
      $scope.nextDate = $moment($scope.date).add(1, 'd').format 'YYYY-MM-DD'
      $scope.nextDate = null if $moment($scope.nextDate).isAfter $moment()

    refreshDiaryData = ->
      $scope.diaryStatus = 'loading'
      Diary.get(date: $scope.date).$promise.then (diary) ->
        $scope.diaryStatus = 'loaded'
        $scope.diary = diary
        $scope.notes = $scope.diary.notes
        diary
      .catch (resp) ->
        if resp.status is 404
          $scope.diary = null
          $scope.notes = []
          $scope.diaryStatus = 'loaded'
        else
          $scope.diaryStatus = 'failed'
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
      unless theNewNote = _($scope.notes).find(creating: true)
        theNewNote = new Note creating: true
        $scope.notes.push theNewNote

      $scrollTo('#main-container .note:last-child', 300).then ->
        theNewNote.focus = true

    $scope.deleteNewNote = ->
      _($scope.notes).remove {creating: true}, destructive: true

    $scope.submitNewNote = (note) ->
      return unless note.content
      $scope.submittingNewNotePromise = note.$save().then refreshDiaryData

    $scope.user = User.get()
    $scope.date = $stateParams.date

    # 可选值 loading, loaded, failed
    $scope.diaryStatus = 'loading'

    $scope.user.$promise.then (user) ->
      return unless user.destroyed()
      $state.go 'deleted'

    $scope.$watch 'date', (date) ->
      refreshDateRef()
      refreshDiaryData()

])
