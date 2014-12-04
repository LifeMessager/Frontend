angular.module('ui.bootstrap')

.config([
  '$modalProvider'
  ($modalProvider) ->
    $modalProvider.options = {
      backdrop: true
    }
])
