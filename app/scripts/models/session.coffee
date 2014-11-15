angular.module('app.models')

.factory('Session', [
  '$http', 'argsHolder'
  ($http ,  argsHolder) ->
    class Session
      @$create: argsHolder 'params-data', (params, data, success, error) ->
        $http.post '/users/login_mail', data, {params, modelAction: true, callbacks: {success, error}}
])
