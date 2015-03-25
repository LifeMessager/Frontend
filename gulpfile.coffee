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

getVendorFiles = ->
  vendorFiles = mainBowerFiles().concat(glob.sync 'vendor/**/*')
  _.groupBy vendorFiles, (filepath) ->
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
    src: 'app/**/*.coffee'
    watch: ['app/**/*.coffee', '!app/scripts/vendor.coffee']
    dest: 'public/scripts/'
  styles:
    src: ['app/**/*.styl', '!app/**/_*.styl']
    watch: 'app/**/*.styl'
    dest: 'public/styles/'
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
  stream = gulp.src [PATHS.scripts.src, '!app/scripts/vendor.coffee']
    .pipe gulp_order(['**/*.js', '**/index.coffee'])
    .pipe gulp_coffee().on 'error', gulp_util.log
    .pipe gulp_concat('tmp.js')
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

gulp.task 'vendor', ->
  vendorFiles = getVendorFiles()
  streams = []

  stream = gulp.src 'app/scripts/vendor.coffee'
    .pipe gulp_coffee().on 'error', gulp_util.log
    .pipe gulp_concat('tmp.js')
    .pipe es.map (data, callback) ->
      callback null, data.contents.toString()
  streams.push(browserify(stream).bundle()
    .pipe gulp_sourceStream('vendor.js')
    .pipe gulp.dest PATHS.scripts.dest
  )

  unless _(vendorFiles.scripts).isEmpty()
    streams.push(gulp.src vendorFiles.scripts
      .pipe gulp_if '**/*.coffee', gulp_coffee().on 'error', gulp_util.log
      .pipe gulp_concat 'bower-vendor.js'
      .pipe gulp.dest PATHS.scripts.dest
    )

  unless _(vendorFiles.styles).isEmpty()
    streams.push(gulp.src vendorFiles.styles
      .pipe gulp_concat 'bower-vendor.css'
      .pipe gulp.dest PATHS.styles.dest
    )

  mergeStream streams...

gulp.task 'server', ->
  gulp_connect.server(
    port: 13000
    root: 'public'
    livereload: true
  )

gulp.task 'watch', ->
  _.forEach PATHS, (paths, type) ->
    watchPath = paths.watch or paths.src
    gulp.task "reload_#{type}", [type], ->
      gulp.src(watchPath).pipe gulp_connect.reload()
    gulp.watch watchPath, ["reload_#{type}"]

  gulp.task "reload_vendor", ['vendor'], ->
    gulp.src([
      "#{PATHS.scripts.dest}/vendor.js"
      "#{PATHS.scripts.dest}/bower-vendor.js"
      "#{PATHS.scripts.dest}/bower-vendor.css"
    ]).pipe gulp_connect.reload()
  gulp.watch ['bower.json', 'app/scripts/vendor.coffee', 'vendor/**/*'], ['reload_vendor']
  return

gulp.task 'build', ['assets', 'partials', 'scripts', 'styles', 'vendor']

gulp.task 'default', ['build', 'server', 'watch']
