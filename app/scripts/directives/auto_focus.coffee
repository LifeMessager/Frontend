
angular.module('app.directives')

.directive('appAutofocus', [
  '$parse', '$timeout'
  ($parse ,  $timeout) ->
    (scope, $elem, attrs) ->
      setter = $parse(attrs.appAutofocus).assign
      scope.$watch attrs.appAutofocus, (needfocus) ->
        return unless needfocus
        $timeout $elem.focus.bind($elem), 0
        setter? scope, false

])
