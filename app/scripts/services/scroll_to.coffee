angular.module('app.services')

.factory('$scrollTo', [
  '$window', '$q'
  ($window ,  $q) ->
    (target, duration, settings) ->
      if _(duration).isObject()
        settings = duration
        duration = 0
      if _(settings).isFunction()
        settings = onAfter: settings
      settings ?= {}

      onAfter = settings.onAfter
      settings.onAfter = ->
        onAfter?.apply this, arguments...
        defer.resolve()

      defer = $q.defer()
      $window.$.scrollTo target, duration, settings
      defer.promise
])
