angular.module('app.controllers')

.controller('DiaryController', [
  '$scope', '$rootScope', '$stateParams', '$state', '$moment', '$q', '$modal', '$scrollTo', 'Session', 'User', 'Diary', 'Note'
  ($scope ,  $rootScope ,  $stateParams ,  $state ,  $moment ,  $q ,  $modal ,  $scrollTo ,  Session ,  User ,  Diary ,  Note) ->
    nextTick = (callback) ->
      return unless callback?
      setTimeout callback, 0

    refreshDateNav = ->
      $scope.previousDate = $moment($scope.date).subtract(1, 'd').toDate()
      $scope.nextDate = $moment($scope.date).add(1, 'd').toDate()
      $scope.nextDate = null if $moment($scope.nextDate).isAfter $moment()

    refreshDiaryData = ->
      date = $moment($scope.date).format 'YYYY-MM-DD'
      $scope.diaryStatus = 'loading'
      Diary.get({date}).$promise.then (diary) ->
        $scope.diaryStatus = 'loaded'
        $scope.diary = diary
        $scope.notes = $scope.diary.notes
        $scope.loadDiaryDefer.resolve()
        diary
      .catch (resp) ->
        if resp.status is 404
          $scope.diary = null
          $scope.notes = []
          $scope.diaryStatus = 'loaded'
          $scope.loadDiaryDefer.resolve()
        else
          $scope.diaryStatus = 'failed'
          $scope.loadDiaryDefer.reject()
        $q.reject resp

    $scope.logout = ->
      Session.clean()
      $state.go 'home'

    $scope.showSettings = ->
      $modal.open(
        templateUrl: 'partials/diary/settings.html'
        controller: 'SettingsController'
      )

    $scope.newNote = do ->
      newNote = ->
        unless theNewNote = _($scope.notes).find(creating: true)
          theNewNote = new Note creating: true, focus: true
          $scope.notes.push theNewNote

        nextTick ->
          $scrollTo('#main-container .note:last-child', 200).then ->
            theNewNote.focus = true

      ->
        unless isToday = !$scope.nextDate
          $scope.date = $moment().toDate()
          nextTick -> $rootScope.$broadcast 'DiaryController:newNote'
        else
          $scope.loadDiaryDefer.promise.then newNote

    $scope.deleteNewNote = ->
      _($scope.notes).remove {creating: true}, destructive: true

    $scope.submitNewNote = (note) ->
      return unless note.content
      $scope.submittingNewNotePromise = note.$save().then refreshDiaryData

    $scope.user = User.get()
    $scope.date = $stateParams.date
    $scope.loadDiaryDefer = $q.defer()
    refreshDateNav()
    refreshDiaryData()

    # 可选值 loading, loaded, failed
    $scope.diaryStatus = 'loading'

    $scope.user.$promise.then (user) ->
      return unless user.destroyed()
      $state.go 'deleted'

    $scope.$watch 'date', (date) ->
      $state.go '.', {date}

    $scope.$on 'DiaryController:newNote', $scope.newNote

])
