gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
sass = require 'gulp-sass'
uglify = require 'gulp-uglify'
through = require 'through2'
runSequence = require 'run-sequence'
path = require 'path'
pkg = require '../package.json'

gulp.task 'compile.coffee', ->
  gulp.src 'src/**/*.coffee'
    .pipe coffee().on('error', gutil.log)
    .pipe through.obj headerTransform()
    .pipe gulp.dest('dist/')

gulp.task 'compile.sass', ->
  gulp.src 'src/**/*.scss'
    .pipe sass().on('error', sass.logError)
    .pipe through.obj headerTransform()
    .pipe gulp.dest('dist/')

gulp.task 'compile.uglify', ->
  gulp.src ['dist/**/*.js', '!dist/**/*.min.js']
    .pipe uglify()
    .pipe through.obj headerTransform('simple')
    .pipe through.obj (file, encoding, done) ->
      dirname = path.dirname file.relative
      extname = path.extname file.relative
      basename = path.basename file.relative, extname
      file.path = path.join file.base, dirname, "#{basename}.min#{extname}"
      @push file
      done()
    .pipe gulp.dest('dist/')

gulp.task 'compile', ->
  runSequence 'compile.coffee', 'compile.uglify'


headerTransform = (type = 'full') ->
  fileHeader =
    full: """
      /**
       * #{pkg.name} v#{pkg.version}
       * #{pkg.homepage}
       *
       * Copyright Mycolorway Design
       * Released under the MIT license
       * #{pkg.homepage}/license.html
       *
       * Date: #{(new Date()).toLocaleString('en-US')}
       */\n\n
    """
    simple: "/* #{pkg.name} v#{pkg.version} | (c) Mycolorway Design | MIT License */\n"

  (file, encoding, done) ->
    headerBuffer = new Buffer fileHeader[type]
    file.contents = Buffer.concat [headerBuffer, file.contents]
    @push file
    done()
