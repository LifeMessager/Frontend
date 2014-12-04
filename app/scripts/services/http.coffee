
angular.module('app.services')

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

.config([
  '$httpProvider'
  ($httpProvider) ->
    $httpProvider.interceptors.push([
      '$window', '$q'
      ($window ,  $q) ->
        responseError: (resp) ->
          if resp.status is 401
            $window._appLogout()
          $q.reject resp
    ])
])

.run([
  '$http', '$moment', '$jstz', 'Session'
  ($http ,  $moment ,  $jstz ,  Session) ->
    $http.defaults.headers.common['Timezone'] = ->
      "#{$moment().toJSON()};;#{$jstz.determine().name()}"

    $http.defaults.headers.common['Authorization'] = ->
      storage = Session.restore()
      "Bearer #{storage}" if storage
])
