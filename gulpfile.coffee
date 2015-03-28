gulp = require 'gulp'
gulp_if = require 'gulp-if'
gulp_util = require 'gulp-util'
gulp_jade = require 'gulp-jade'
gulp_order = require 'gulp-order'
gulp_coffee = require 'gulp-coffee'
gulp_concat = require 'gulp-concat'
gulp_replace = require 'gulp-replace'
gulp_connect = require 'gulp-connect'
gulp_rework = require './scripts/gulp-rework'
gulp_ngCloak = require 'gulp-angular-cloak'
gulp_sourceStream = require 'vinyl-source-stream'
mergeStream = require 'merge-stream'
es = require 'event-stream'

sysPath = require 'path'

Q = require 'q'
_ = require 'lodash'
glob = require 'glob'
browserify = require 'browserify'
mainBowerFiles = require 'main-bower-files'


groupBowerFiles = ->
  files = mainBowerFiles()
  _.groupBy files, (filepath) ->
    switch sysPath.extname filepath
      when '.js', '.coffee' then 'scripts'
      when '.css' then 'styles'
      else 'others'

PATHS = {
  assets:
    src: 'app/assets/**/*'
    dest: 'public/'
  partials:
    src: 'app/partials/**/*.jade'
    dest: 'public/partials/'
  scripts:
    src: 'app/scripts/**/*.coffee'
    dest: 'public/scripts/'
  styles:
    src: 'app/styles/**/*.styl'
    dest: 'public/styles/'
  vendor:
    src: 'app/vendor.coffee'
    dest: 'public/scripts/'
}


gulp.task 'assets', ->
  uneditableExts = 'png jpg gif eot ttf woff svg'.split ' '

  streams = []

  streams.push(gulp.src PATHS.assets.src
    .pipe gulp_if '**/*.jade', gulp_jade(pretty: true, locale: timestamp: Date.now())
    .on 'error', gulp_util.log
    .pipe gulp.dest PATHS.assets.dest
  )

  streams.push(gulp.src 'bower_components/bootstrap/fonts/**/*'
    .pipe gulp.dest PATHS.assets.dest + 'fonts/'
  )

  mergeStream streams...

gulp.task 'partials', ->
  gulp.src PATHS.partials.src
    .pipe gulp_jade(pretty: true).on 'error', gulp_util.log
    .pipe gulp_ngCloak()
    .pipe gulp.dest PATHS.partials.dest

gulp.task 'scripts', ['assets'], ->
  stream = gulp.src PATHS.scripts.src
    .pipe gulp_order(['**/*.js', '**/index.coffee'])
    .pipe gulp_coffee().on 'error', gulp_util.log
    .pipe gulp_concat('app_tmp.js')
    .pipe es.map (data, callback) ->
      callback null, data.contents.toString()
  browserify(stream).bundle()
    .pipe gulp_sourceStream('app.js')
    .pipe gulp.dest PATHS.scripts.dest

gulp.task 'styles', ['assets'], ->
  gulp.src PATHS.styles.src
    .pipe gulp_if '**/*.styl', gulp_rework().on 'error', gulp_util.log
    .pipe gulp_concat 'app.css'
    .pipe gulp.dest PATHS.styles.dest

gulp.task 'bower', ->
  bowerFiles = groupBowerFiles()
  streams = []

  unless _(bowerFiles.scripts).isEmpty()
    streams.push(gulp.src bowerFiles.scripts
      .pipe gulp_if '**/*.coffee', gulp_coffee().on 'error', gulp_util.log
      .pipe gulp_concat 'bower.js'
      .pipe gulp.dest PATHS.scripts.dest
    )

  unless _(bowerFiles.styles).isEmpty()
    streams.push(gulp.src bowerFiles.styles
      .pipe gulp_concat 'bower.css'
      .pipe gulp.dest PATHS.styles.dest
    )

  mergeStream streams...

gulp.task 'vendor', ->
  stream = gulp.src PATHS.vendor.src
    .pipe gulp_order(['**/*.js', '**/index.coffee'])
    .pipe gulp_coffee().on 'error', gulp_util.log
    .pipe gulp_concat('vendor_tmp.js')
    .pipe es.map (data, callback) ->
      callback null, data.contents.toString()
  browserify(stream).bundle()
    .pipe gulp_sourceStream('vendor.js')
    .pipe gulp.dest PATHS.vendor.dest

gulp.task 'server', ->
  gulp_connect.server(
    port: 13000
    root: 'public'
    livereload: true
  )

gulp.task 'watch', ->
  _.forEach PATHS, (paths, type) ->
    gulp.task "reload_#{type}", [type], ->
      gulp.src(paths.src).pipe gulp_connect.reload()
    gulp.watch paths.src, ["reload_#{type}"]

  gulp.task "reload_bower", ['bower'], ->
    gulp.src ["#{PATHS.scripts.dest}/bower.js", "#{PATHS.scripts.dest}/bower.css"]
      .pipe gulp_connect.reload()
  gulp.watch ['bower.json'], ['reload_bower']
  return

gulp.task 'build', ['assets', 'partials', 'scripts', 'styles', 'bower', 'vendor']

gulp.task 'default', ['build', 'server', 'watch']
