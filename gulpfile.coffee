browserify  = require 'browserify'
clean       = require 'gulp-clean'
gulp        = require 'gulp'
manifest    = require 'gulp-manifest'
reactify    = require 'coffee-reactify'
sass        = require 'gulp-sass'
sequence    = require 'gulp-run-sequence'
server      = require 'gulp-server-livereload'
source      = require 'vinyl-source-stream'
sourcemaps  = require 'gulp-sourcemaps'

gulp.task 'default', (cb) ->
  sequence 'clean', ['copy', 'sass', 'script'], 'manifest', 'watch', 'webserver', cb

gulp.task 'script', ->
  b = browserify()
  b.transform(reactify)
  b.add('./src/js/app.coffee')

  b.bundle()
    .on 'error', (err) -> 
      console.error err.toString()
      this.emit("end")
    .pipe(source('app.js'))
    .pipe gulp.dest('./build/assets')

gulp.task 'copy', ->
  gulp.src('./src/images/**').pipe gulp.dest('./build/assets/images')
  gulp.src('./src/*.html').pipe gulp.dest('./build')

gulp.task 'clean', ->
  gulp.src('./build/*').pipe clean({force: true})

gulp.task 'sass', ->
  gulp.src './src/style/app.sass'
    .pipe sourcemaps.init()
      .pipe sass().on('error', sass.logError)
    .pipe sourcemaps.write('./maps')
    .pipe gulp.dest('./build/assets')

gulp.task 'manifest', ->
  gulp.src([ './build/**/*' ], base: './build').pipe(manifest(
    hash: true
    preferOnline: true
    network: [ '*' ]
    filename: 'app.manifest'
    exclude: 'assets/app.manifest')).pipe gulp.dest('./build/assets')

gulp.task 'webserver', ->
  gulp.src('./build')
    .pipe server(
      livereload: true
      open: true)
  
gulp.task 'watch', ->
  gulp.watch ['./src/**/*.sass'],                                         [ 'sass' ]
  gulp.watch ['./src/**/*.cjsx', './src/**/*.coffee', './src/**/*.js'],   [ 'script' ]
  gulp.watch ['./src/*.html', './src/images/**'], ['copy']