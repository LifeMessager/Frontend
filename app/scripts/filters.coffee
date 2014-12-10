'use strict'

### Filters ###

angular.module('app.filters', [])

.filter('formatNoteContent', [
  '$sce'
  ($sce) ->
    (content) ->
      result = _.escape(content).split(/\n\n/).join('</p><p>')
      $sce.trustAsHtml '<p>' + result + '</p>'
])

.filter('moment', [
  '$moment'
  ($moment) ->
    (str, method, args...) ->
      return str unless method
      $moment(str)[method] args...
])
