
angular.module('app.services')

.factory('$storage', [
  '$window'
  ($window) ->
    {localStorage} = $window

    ->
      get: (key) ->
        result = localStorage.getItem key
        return unless result?
        try JSON.parse result
      set: (key, value) ->
        localStorage.setItem key, JSON.stringify value
      del: (key) ->
        localStorage.removeItem key
      forEach: (fn) ->
        _.keys(localStorage).forEach (key) =>
          fn? @get(key), key
])
