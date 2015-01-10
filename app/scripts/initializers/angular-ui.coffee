angular.module('ui.bootstrap')

.config([
  '$modalProvider'
  ($modalProvider) ->
    $modalProvider.options = {
      backdrop: true
    }
])

angular.module('ui.utils', ['ui.keypress'])
