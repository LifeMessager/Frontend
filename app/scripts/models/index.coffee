'use strict'

### Models ###

angular.module('app.models', [
  'ngResource'
  'ng-extra.resource'
])

.constant('BASE_URL', do ->
  if localStorage.dev or location.hostname.match /\.dev/
    '//be.lifemessager.dev/'
  else
    '/api/'
)

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
