'use strict'

### Controllers ###

angular.module('app.controllers', [
  'ng-extra'
  'jm.i18next'
  'ui.bootstrap'
  'app.models'
])

.controller('HomeCtrl', [
  '$scope', 'errorAlert'
  ($scope ,  errorAlert) ->
    $scope.login = ->
])
