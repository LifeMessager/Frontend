
angular.module('app.services')

.factory('$storage', [
  '$window'
  ($window) ->
    {localStorage} = $window

    ->
      get: (key) ->
        localStorage.getItem key
      set: (key, value) ->
        localStorage.setItem key, value
      del: (key) ->
        localStorage.removeItem key
      forEach: (fn) ->
        _.forEach localStorage, fn
])
