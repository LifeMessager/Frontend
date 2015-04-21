angular.module('app.controllers')

.controller('SettingsController', [
  '$scope', '$state', '$q', '$moment', '$jstz', '$dialog', 'User', 'errorAlert'
  ($scope ,  $state ,  $q ,  $moment ,  $jstz ,  $dialog ,  User ,  errorAlert) ->
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

    $scope.destroyAccount = ->
      $dialog.confirm(message: 'copy:settings.confirm_destroy_account').then ->
        user.$destroy().catch errorAlert()
      .then ->
        user.deleted_at = $moment().toJSON()
        $scope.$dismiss? 'close'
        $state.go 'deleted'

    do ->
      $scope.editEmailStart = ->
        $scope.emailEditing = true
        $scope.targetEmail = user.email

      $scope.editEmailFinish = ($event) ->
        $event.preventDefault() if $event
        if $scope.targetEmail isnt user.email
          $scope.changeEmailPromise = user.$applyChangeEmail(null, email: $scope.targetEmail).then ->
            $scope.emailEditing = false
            $scope.changeEmailApplySendSuccess = true
          .catch errorAlert()
          .finally ->
            delete $scope.changeEmailPromise

      $scope.editEmailCancel = ->
        $scope.emailEditing = false

    user = User.getCurrentUser()
    $scope.userSnapshot = null
    $scope.avaliableAlertTimes = _.range(0, 24).map (hour) -> "#{if hour < 10 then "0" else ""}#{hour}:00"
    $scope.avaliableTimezones = _.map $jstz.olson.timezones, formatTimezoneOffset

    user.$promise.then (user) ->
      $scope.userSnapshot = angular.clean user
])
