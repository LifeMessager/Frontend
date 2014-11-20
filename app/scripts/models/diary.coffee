
angular.module('app.models')

.factory('Diary', [
  '$resource'
  ($resource) ->
    Diary = $resource(
      '/diaries/:date'
    )

    Diary
])
