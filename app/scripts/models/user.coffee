
angular.module('app.models')

.factory('User', [
  '$resource', '$rootScope', '$http', '$moment', '$q', 'argsHolder'
  ($resource ,  $rootScope ,  $http ,  $moment ,  $q ,  argsHolder) ->
    User = $resource(
      '/users/:id'
      {id: '@id'}
      getCurrentUser:
        url: '/user'
        method: 'get'
      update:
        method: 'patch'
        normalize: true
      subscribe:
        url: '/users/:id/subscription'
        method: 'put'
        normalize: true
      unsubscribe:
        url: '/users/:id/subscription'
        method: 'delete'
        headers:
          Authorization: -> "unsubscribe #{User.getCurrentUser().unsubscribe_token}"
      recover:
        url: '/users/:id/regain'
        method: 'post'
        transformRequest: -> ''
      applyChangeEmail:
        url: '/users/:id/change_email_applies'
        method: 'post'
        normalize: true
    )

    User.languages = [
      'zh-Hans-CN'
      'zh-Hant-TW'
      'en'
    ]

    User.wrapStaticMethod 'getCurrentUser', (fn) ->
      currentUser = null
      argsHolder 'params', (params = {}, success, error) ->
        currentUser = null if params.refresh
        unless currentUser
          currentUser = fn.apply this, arguments
        currentUser

    User.wrapStaticMethod 'get', (fn) ->
      argsHolder 'params', (params = {}, success, error) ->
        cb = if params.id? then fn else User.getCurrentUser
        cb.apply this, arguments

    User.wrapStaticMethod 'getCurrentUser', (fn) ->
      cache = null
      argsHolder 'params', (params = {}, success, error) ->
        unless _(params).isEmpty()
          return fn.apply this, arguments
        return cache if cache
        user = fn.apply this, arguments
        user.$promise.then ->
          cache = user
          $rootScope.$broadcast 'model:user:login', user
          user
        user

    User.wrapInstanceMethod 'subscribe', (fn) ->
      argsHolder 'params-data', (params, data, success, error) ->
        fn.apply(this, arguments).then (resp) =>
          @subscribed = true
          resp

    User.wrapInstanceMethod 'unsubscribe', (fn) ->
      argsHolder 'params', (params, success, error) ->
        fn.apply(this, arguments).then (resp) =>
          @subscribed = false
          resp

    User::$changeEmail = argsHolder 'params', (params = {}, success, error) ->
      headersGetterHolder = null
      errorHandler = (resp) ->
        error? resp
      successHandler = (data, headersGetter) ->
        headersGetterHolder = headersGetter

      token = params.token
      delete params.token
      params.id or= @id
      headers = Authorization: "change_email #{token}"
      callbacks = success: successHandler, error: errorHandler
      options = {params, headers, modelAction: true, callbacks}
      $http.put("/users/:id/email", null, options).then =>
        @$fetch()
      .then ->
        success? null, headersGetterHolder
        return

    User::destroyed = ->
      @deleted_at and $moment(@deleted_at).isValid()

    User
])
