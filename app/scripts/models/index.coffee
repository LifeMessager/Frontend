'use strict'

### Models ###

angular.module('app.models', [
  'ngResource'
])

.constant('BASE_URL', 'http://be.diary-service.dev/')

.value('defaultActions', {
  query:
    classMethod: true
    method: 'get'
    isArray: true
  get:
    classMethod: true
    method: 'get'
  create:
    classMethod: true
    method: 'post'
  delete:
    classMethod: true
    method: 'delete'

  fetch:
    instanceMethod: true
    method: 'get'
  update:
    instanceMethod: true
    method: 'patch'
  destroy:
    instanceMethod: true
    method: 'delete'
})

# default resource action
.config(['$provide', ($provide) ->
  $provide.decorator('$resource', [
    '$delegate', 'defaultActions'
    ($resource,   defaultActions) ->
      (url, paramDefaults, actions) ->
        action = angular.extend {}, defaultActions, actions
        $resource url, paramDefaults, action
  ])
])

# auto prefix resource request url
.config(['$provide', ($provide) ->
  $provide.decorator('$resource', [
    '$delegate', 'BASE_URL'
    ($resource,   BASE_URL) ->
      addUrlPrefix = (url) ->
        url.replace /^\//, BASE_URL

      (url, paramDefaults, actions) ->
        url = addUrlPrefix url
        return $resource(url, paramDefaults, actions) unless actions
        actions = angular.copy actions
        _(actions).forEach (opt, action) ->
          return unless opt.url?
          opt.url = addUrlPrefix opt.url
        $resource url, paramDefaults, actions
  ])
])

# 让 $http 的表现和 $resource 的 action 更相似
.config(['$provide', ($provide) ->
  $provide.decorator('$http', [
    '$delegate', '$q', 'BASE_URL'
    ($http     ,  $q ,  BASE_URL) ->
      makePromiseLike$resource = (promise, config) ->
        promise.then((resp) ->
          config.callbacks?.success? resp.data, resp.headers
          resp.data
        , (resp) ->
          config.callbacks?.error? resp
          $q.reject resp
        )

      createShortMethods = ->
        angular.forEach arguments, (method) ->
          replacement[method] = (url, config) ->
            replacement angular.extend(config or {}, {method, url})

      createShortMethodsWithData = ->
        angular.forEach arguments, (method) ->
          replacement[method] = (url, data, config) ->
            replacement angular.extend(config or {}, {method, url, data})

      replacement = (requestConfig) ->
        unless requestConfig.modelAction
          return $http requestConfig

        startWithSlashRE = /^\//
        config = _.clone requestConfig
        if startWithSlashRE.test config.url
          config.url = config.url.replace startWithSlashRE, BASE_URL
        config.url = config.url.replace /\:([^\/]+)/g, (match, $1) ->
          param = config.params[$1]
          delete config.params[$1]
          param or $1
        makePromiseLike$resource $http(config), config

      createShortMethods('get', 'delete', 'head', 'jsonp')
      createShortMethodsWithData('post', 'put')
      replacement.defaults = $http.defaults

      replacement
  ])
])

.factory('argsHolder', [
  '$window'
  ({Args}) ->
    (type, callback) ->
      switch type
        when 'params', 'data'
          options = [
            {params: Args.OBJECT | Args.Optional}
            {success: Args.FUNCTION | Args.Optional}
            {error: Args.FUNCTION | Args.Optional}
          ]
        when 'params-data'
          options = [
            {params: Args.OBJECT | Args.Optional}
            {data: Args.OBJECT | Args.Optional}
            {success: Args.FUNCTION | Args.Optional}
            {error: Args.FUNCTION | Args.Optional}
          ]

      ->
        {params, data, success, error} = Args options, arguments
        if type is 'params-data'
          if params? and not data?
            [data, params] = [params, null]
          callback.call this, params, data, success, error
        else
          callback.call this, params, success, error
])
