angular.module('app.controllers')

.controller('SettingsController', [
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
