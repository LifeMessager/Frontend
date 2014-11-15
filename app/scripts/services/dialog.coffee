
angular.module('app.services')

.config(['$provide', ($provide) ->
  $provide.decorator('$dialog', [
    '$delegate', '$i18next'
    ($dialog   ,  $i18next) ->
      'alert confirm prompt'.split(' ').forEach (method) ->
        originMethod = $dialog[method]
        $dialog[method] = (options) ->
          if options.i18n isnt false
            options = angular.extend {}, options, message: $i18next(options.message)
          originMethod.call this, options
      $dialog
  ])
])
