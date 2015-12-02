gulp           = require 'gulp'
clean          = require 'gulp-clean'
browserify     = require 'browserify'
browserifyInc  = require 'browserify-incremental'
sass           = require 'gulp-sass'
reactify       = require 'coffee-reactify'
source         = require 'vinyl-source-stream'
sourcemaps     = require 'gulp-sourcemaps'
webserver      = require 'gulp-webserver'
sequence       = require 'gulp-run-sequence'
manifest       = require 'gulp-manifest'
bower          = require 'gulp-bower'

config =
  sassPath: './src/style'
  bowerDir: './bower_components'

gulp.task 'default', (cb) ->
  sequence 'clean', 'bower', ['copy', 'sass', 'script'], 'manifest', 'watch', 'webserver', cb

gulp.task 'bower', ->
  bower()
  .pipe(gulp.dest(config.bowerDir))

gulp.task 'script', ->
  b = browserify {
    fullPaths: true,
    cache: {}
  }
  browserifyInc(b, {cacheFile: './browserify-cache.json'})
  b.transform(reactify)
  b.add('./src/js/app.cjsx')

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
      .pipe sass(
        loadPath: [
          config.sassPath
          config.bowerDir + '/bootstrap-sass-official/assets/stylesheets'
        ]
      ).on('error', sass.logError)
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
    .pipe(
      webserver(
        fallback: 'index.html'
        livereload: true
      )
    )

gulp.task 'watch', ->
  gulp.watch ['./src/**/*.sass'],                 [ 'sass' ]
  gulp.watch ['./src/**/*.{cjsx, coffee, js}'],   [ 'script' ]
  gulp.watch ['./src/*.html', './src/images/**'], [ 'copy' ]
