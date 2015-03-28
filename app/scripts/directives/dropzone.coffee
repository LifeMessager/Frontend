Dropzone = require 'dropzone'

angular.module('app.directives')

.run([
  '$templateCache'
  ($templateCache) ->
    # From https://github.com/enyo/dropzone/blob/202824c23a182f4ea4b3d8508547dd029f692d58/src/dropzone.coffee#L484
    $templateCache.put('dropzone/preview.html', """
      <div class="dz-preview dz-file-preview">
        <div class="dz-image"><img data-dz-upload data-dz-thumbnail /></div>
      </div>
    """)
])

.directive('dropzone', [
  '$window', '$templateCache'
  ($window ,  $templateCache) ->
    makePageDropable = do ->
      findDragListener = (dropzone) ->
        dropzone.listeners.filter((listener) ->
          _(listener.events).keys().contains 'dragend'
        )[0]

      ($scope, dropzone) ->
        return unless $scope.dzPageDropable
        dragListener = findDragListener dropzone
        bodyElem = angular.element('body')[0]
        _.forEach dragListener.events, (fn, eventName) ->
          dragListener.element.removeEventListener eventName, fn
          bodyElem.addEventListener eventName, fn
        $scope.$on '$destroy', ->
          _.forEach dragListener.events, (fn, eventName) ->
            bodyElem.removeEventListener eventName, fn

    bindNgModel = ($scope, ngModel, dropzone) ->
      dropzone.on 'addedfile', (newfile) ->
        if $scope.dzMultiple
          ngModel.$setViewValue ngModel.$viewValue.push newfile
        else
          dropzone.files.forEach (file) ->
            return if file is newfile
            dropzone.removeFile file
          ngModel.$setViewValue newfile

      dropzone.on 'removedfile', (file) ->
        if $scope.dzMultiple
          _.remove ngModel.$viewValue, file
          ngModel.$setViewValue ngModel.$viewValue
        else
          ngModel.$setViewValue null

    bindUploadEvent = ($elem, dropzone) ->
      $elem.on 'click', '[data-dz-upload]', (event) ->
        dropzone.hiddenFileInput.click()

    generateOptions = ($scope, $elem, attrs, ngModel) ->
      options =
        url: 'we do not need it'
        maxFilesize: $scope.dzMaxFilesize
        uploadMultiple: $scope.dzMultiple
        clickable: $scope.dzClickable
        acceptedFiles: $scope.dzAccept
        thumbnailWidth: $scope.dzThumbnailWidth
        thumbnailHeight: $scope.dzThumbnailHeight
        previewTemplate: $templateCache.get('dropzone/preview.html')
        init: ->
          bindNgModel $scope, ngModel, this
          bindUploadEvent $elem, this
          makePageDropable $scope, this

      if $scope.dzPageDropable
        $body = angular.element 'body'
        dzOptions = angular.extend options, {
          drop: (e) -> $body.removeClass "dz-drag-hover"
          dragstart: angular.noop
          dragend: (e) -> $body.removeClass "dz-drag-hover"
          dragenter: (e) -> $body.addClass "dz-drag-hover"
          dragover: (e) -> $body.addClass "dz-drag-hover"
          dragleave: (e) -> $body.removeClass "dz-drag-hover"
        }

      options

    require: 'ngModel'
    scope:
      dzMaxFilesize: '='
      dzMultiple: '='
      dzClickable: '='
      dzAccept: '='
      dzPageDropable: '='
      dzThumbnailWidth: '='
      dzThumbnailHeight: '='
    link: ($scope, $elem, attrs, ngModel) ->
      ngModel.$validators.required = (modelValue, viewValue) ->
        not attrs.required or not _(viewValue).isEmpty()

      if not ngModel.$viewValue and $scope.dzMultiple
        ngModel.$setViewValue []

      $elem.dropzone generateOptions($scope, $elem, attrs, ngModel)
])
