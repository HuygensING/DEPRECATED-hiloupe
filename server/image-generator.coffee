rimraf = require 'rimraf'
globby = require 'globby'
fs = require 'fs'
Generator = require './generator'

imgPaths = null
outputDir = '../static/images/generated'

start = process.hrtime()

generateImages = ->
	inputPath = imgPaths.pop()

	process.exit() unless inputPath?

	generator = new Generator(outputDir, inputPath)
	generator.on 'done', ->
		diff = process.hrtime(start)
		s = diff[0]
		ms = Math.round diff[1]/1000000
		console.log "IT TOOK #{s}s #{ms}ms"

# Remove and create the main dir
rimraf outputDir, (err) ->
	fs.mkdirSync(outputDir)

	# Get all imag epaths
	globby ['../static/images/facsimiles/*.*'], (err, files) ->
		console.log files
		imgPaths = files

		# imgPaths.pop()
		# imgPaths.pop()
		

		console.log imgPaths

		# Start looping the paths.
		generateImages()