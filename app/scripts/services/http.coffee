
angular.module('app.services')

.run([
  '$http', '$moment'
  ($http ,  $moment) ->
    $http.defaults.headers.common['Timezone'] = ->
      "#{$moment().toJSON()};;#{jstz.determine().name()}"
])
