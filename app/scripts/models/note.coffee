angular.module('app.models')

.factory('Note', [
  '$resource', 'argsHolder'
  ($resource ,  argsHolder) ->
    Note = $resource(
      '/notes/:id'
      {id: '@id'}
      saveImageNote:
        method: 'post'
        headers: {'Content-Type': undefined}
        withCredentials: true
        transformRequest: (data, headersGetter) ->
          formData = new FormData
          _.forEach data, (value, key) ->
            formData.append key, value
          formData
    )

    originSave = Note.save
    Note.save = argsHolder 'params-data', (params, data, success, error) ->
      method = if data.type is 'image' then Note.saveImageNote else originSave
      method.apply this, arguments

    Note::type = 'text'

    Note
])
