
through = require 'through2'
cssWhitespaceCompiler = require 'css-whitespace'
gulp_util = require 'gulp-util'

rework = require 'rework'
rework_calc = require 'rework-calc'
rework_vars = require 'rework-vars'
rework_shade = require 'rework-shade'
rework_import = require 'rework-import'
rework_inherit = require 'rework-inherit'
rework_ease = require 'rework-plugin-ease'
rework_mixin = require 'rework-plugin-mixin'
rework_colors = require 'rework-plugin-colors'
rework_inline = require 'rework-plugin-inline'
rework_references = require 'rework-plugin-references'

mixins = {
  appearance: (value) ->
    '-webkit-appearance': value
}

module.exports = ->
  through.obj (file, enc, cb) ->
    if file.isStream()
      @emit 'error', new gulp_util.PluginError 'gulp-rework', 'Streaming not supported'
      return cb()

    css = cssWhitespaceCompiler file.contents.toString()
    file.contents = new Buffer(rework(css)
      .use(rework_import
        path: 'styles/app.styl'
        base: 'src/'
        transform: cssWhitespaceCompiler
      )
      .use rework_vars()
      .use rework_calc
      .use rework_shade()
      .use rework_mixin mixins
      .use rework_inherit()
      .use rework_ease()
      .use rework_references()
      .use rework_colors()
      .use rework_inline('app/assets/images/')
      .toString()
    )

    @push file
    cb()
