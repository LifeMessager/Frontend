angular.module('app.models')

.factory('Session', [
  '$http', '$storage', '$moment', 'argsHolder'
  ($http ,  $storage ,  $moment ,  argsHolder) ->
    STORAGE_KEY = "#{$moment().format 'L'}-token"

    clean = ->
      $storage().forEach (value, key) ->
        return unless /-token$/.test key
        return if STORAGE_KEY is key
        $storage().del key
        return

    class Session
      @$create: argsHolder 'params-data', (params, data, success, error) ->
        $http.post '/users/login_mail', data, {params, modelAction: true, callbacks: {success, error}}

      @restore: ->
        clean()
        $storage().get STORAGE_KEY

      @clean: ->
        clean()
        $storage().del STORAGE_KEY

      constructor: ({@token}) ->
        clean()
        $storage().set STORAGE_KEY, @token
        return
])
