gulp = require 'gulp'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
rimraf = require 'gulp-rimraf'
jade = require 'gulp-jade'
stylus = require 'gulp-stylus'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
minifyCss = require 'gulp-minify-css'
streamify = require 'gulp-streamify'
preprocess = require 'gulp-preprocess'

source = require 'vinyl-source-stream'
browserify = require 'browserify'
watchify = require 'watchify'
nib = require 'nib'
browserSync = require 'browser-sync'
modRewrite = require 'connect-modrewrite'
rsync = require('rsyncwrapper').rsync
url = require('url')
proxy = require('proxy-middleware')
pkg = require './package.json'

logError = (msg) ->
  gutil.log gutil.colors.red(msg)
  process.exit(1)

if process.env.NODE_ENV? and (process.env.NODE_ENV isnt 'dev' and process.env.NODE_ENV isnt 'prod')
  logError 'NODE_ENV should be "dev" or "prod".'

devDir = './compiled'
prodDir = './dist'

baseDir = if process.env.NODE_ENV is 'prod' then prodDir else devDir
env = if process.env.NODE_ENV is 'prod' then 'production' else 'development'

context =
  VERSION: pkg.version
  ENV: env
  BASEDIR: baseDir

stylusPaths = [
  './src/stylus/**/*.styl'
]

gulp.task 'server', ['watch', 'watchify'], ->
  proxyOptions = url.parse('http://localhost:3000')
  proxyOptions.route = '/hiloupe'

  browserSync.init null,
    server:
      baseDir: './compiled'
      middleware: [proxy(proxyOptions)]

gulp.task 'stylus', ->
  gulp.src(stylusPaths)
    .pipe(stylus(
      use: [nib()]
    ))
    .pipe(concat("main-#{context.VERSION}.css"))
    .pipe(gulp.dest("#{context.BASEDIR}/css"))
    .pipe(browserSync.reload(stream: true))

gulp.task 'uglify', ->
  gulp.src("#{devDir}/js/*")
    .pipe(concat("main-#{context.VERSION}.js", newLine: '\r\n;'))
    .pipe(uglify())
    .pipe(gulp.dest(prodDir+'/js/'))

gulp.task 'minify-css', ->
  gulp.src("#{devDir}/css/main-#{context.VERSION}.css")
    .pipe(minifyCss())
    .pipe(gulp.dest(prodDir+'/css'))

gulp.task 'clean', -> gulp.src(context.BASEDIR+'/*').pipe(rimraf())

gulp.task 'copy-static', -> gulp.src('./static/**/*').pipe(gulp.dest("#{context.BASEDIR}"))

gulp.task 'compile', ['clean'], ->
  if context.ENV is 'production'
    gulp.start 'build', ->
      logError "Error: The compile task has not run! Compile the project only with NODE_ENV=dev! (#{context.BASEDIR} is re-build!)"
  else
    gulp.start 'copy-static', 'browserify', 'browserify-libs', 'jade', 'stylus'

gulp.task 'build', ['clean'], ->
  if context.ENV is 'development'
    gulp.start 'compile', ->
      logError "Error: The build task has not run! Build project only with NODE_ENV=prod! (#{context.BASEDIR} is re-compiled!)"
  else
    gulp.start 'jade', 'copy-hilib-images', 'uglify', 'minify-css'


gulp.task 'jade', ->
  gulp.src('./src/index.jade')
    .pipe(jade())
    .pipe(preprocess(context: context))
    .pipe(gulp.dest(context.BASEDIR))
    .pipe(browserSync.reload(stream: true))

gulp.task 'watch', ->
  logError 'Watch files only in "development".' if context.ENV is 'production'
  gulp.watch ['./src/index.jade'], ['jade']
  gulp.watch [stylusPaths], ['stylus']

createBundle = (watch=false) ->
  args =
    entries: './src/coffee/index.coffee'
    extensions: ['.coffee']
    debug: true

  bundler = if watch then watchify(args) else browserify(args)

  bundler.transform('coffeeify')
  # bundler.transform('coffee-reactify')
  bundler.transform('envify')

  bundler.exclude 'ampersand-state'
  bundler.exclude 'ampersand-collection'
  bundler.exclude 'ampersand-view'

  rebundle = ->
    gutil.log('Watchify rebundling') if watch
    bundler.bundle()
      .on('error', ((err) -> gutil.log("Bundling error ::: "+err)))
      .pipe(source("src-#{context.VERSION}.js"))
      .pipe(gulp.dest("#{context.BASEDIR}/js"))
      .pipe(browserSync.reload({stream:true, once: true}))
      .on('error', gutil.log)

  bundler.on('update', rebundle)

  rebundle()

gulp.task 'browserify', -> createBundle false
gulp.task 'watchify', -> createBundle true

gulp.task 'browserify-libs', ->
  libs =
    'ampersand-state': './node_modules/ampersand-state/ampersand-state'
    'ampersand-collection': './node_modules/ampersand-collection/ampersand-collection'
    'ampersand-view': './node_modules/ampersand-view/ampersand-view'

  paths = Object.keys(libs).map (key) -> libs[key]

  bundler = browserify paths

  for own id, path of libs
    bundler.require path, expose: id

  gutil.log('Browserify: bundling libs')
  bundler.bundle()
    .pipe(source("libs-#{pkg.version}.js"))
    .pipe(gulp.dest("#{context.BASEDIR}/js"))

gulp.task 'default', ['server']