angular.module('app.models')

.factory('Session', [
  '$http', '$storage', '$moment', 'argsHolder'
  ($http ,  $storage ,  $moment ,  argsHolder) ->
    TODAY_STORAGE_KEY = "#{$moment().format 'L'}-token"
    STORAGE_KEY = 'token'

    clean = ->
      $storage().forEach (value, key) ->
        return unless /-token$/.test key
        return if TODAY_STORAGE_KEY is key
        $storage().del key
        return

    class Session
      @$create: argsHolder 'params-data', (params, data, success, error) ->
        $http.post '/sessions/emails', data, {params, modelAction: true, callbacks: {success, error}}

      @exist: (type) ->
        if type is 'today'
          $storage().get(TODAY_STORAGE_KEY)?
        else
          $storage().get(STORAGE_KEY)?

      @restore: ->
        clean()
        $storage().get(STORAGE_KEY) or $storage().get(TODAY_STORAGE_KEY)

      @save: (session) ->
        session = token: session unless _(session).isObject()
        if $moment(session.expired_at).isAfter $moment().add(1, 'day')
          $storage().set STORAGE_KEY, session
        else
          $storage().set TODAY_STORAGE_KEY, session

      @clean: ->
        clean()
        $storage().del STORAGE_KEY
        $storage().del TODAY_STORAGE_KEY

      constructor: (session) ->
        clean()
        Session.save session
        angular.copy session, this
        return

      $renew: argsHolder 'params', (params, success, error) ->
        options = {params, modelAction: true, callbacks: {success, error}}
        $http.post('/sessions', null, options).then (session) =>
          Session.save session
          angular.copy session, this
          this

])
