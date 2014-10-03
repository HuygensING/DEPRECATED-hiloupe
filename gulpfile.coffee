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

prodDir = './dist'

### BUILD ###

gulp.task 'build', ['browserify', 'stylus']

gulp.task 'cleanDist', -> gulp.src("#{prodDir}/*").pipe(rimraf())

gulp.task 'stylus', ['cleanDist'], ->
	gulp.src('./src/stylus/**/*.styl')
		.pipe(stylus(
			use: [nib()]
		))
		.pipe(concat("hiloupe.css"))
		.pipe(minifyCss())
		.pipe(gulp.dest(prodDir))

### /BUILD ###

createBundle = (watch=false) ->
	args =
		entries: './src/coffee/views/main.coffee'
		extensions: ['.coffee']
		debug: true

	bundler = if watch then watchify(args) else browserify(args)

	bundler.transform('coffeeify')
	bundler.transform('envify')

	rebundle = ->
		gutil.log('Watchify rebundling') if watch
		bundler.bundle(standalone: 'hiloupe')
			.on('error', ((err) -> gutil.log("Bundling error ::: "+err)))
			.pipe(source("hiloupe.js"))
			.pipe(gulp.dest(prodDir))

	bundler.on('update', rebundle)

	rebundle()

gulp.task 'watch', ->
	gulp.watch ['./src/stylus/**/*.styl'], ['stylus']

gulp.task 'browserify', ['cleanDist'], -> createBundle false
gulp.task 'watchify', -> createBundle true

gulp.task 'default', ['watch', 'watchify']