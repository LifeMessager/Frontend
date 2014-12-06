angular.module('app.models')

.factory('Note', [
  '$resource'
  ($resource) ->
    Note = $resource(
      '/notes/:id'
      {id: '@id'}
    )

    Note
])
