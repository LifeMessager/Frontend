angular.module('ng')

.factory('$kbd', [
  '$window'
  ($window) ->
    class Kbd extends $window.Mousetrap
      constructor: (@scope) ->
        super()

      bind: (keys, callback, action) ->
        self = this

        wrappedCallback = ->
          self.scope.$apply =>
            callback.apply this, arguments

        super keys, wrappedCallback, action

])

.config([
  '$provide'
  ($provide) ->
    $provide.decorator('$controller', [
      '$delegate', '$kbd'
      ($controller, $kbd) ->
        (expression, locals, later, ident) ->
          $scope = locals.$scope
          $injectKbd = new $kbd $scope
          locals['$kbd'] = $injectKbd
          $scope.$on '$destroy', -> $injectKbd.destroy()
          $controller expression, locals, later, ident
    ])
])
