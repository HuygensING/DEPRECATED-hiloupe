rimraf = require 'rimraf'
globby = require 'globby'
fs = require 'fs'
Generator = require './generator'

imgPaths = null
outputDir = '../static/images/generated'

generateImages = ->
	inputPath = imgPaths.pop()

	process.exit() unless inputPath?

	generator = new Generator(outputDir, inputPath)

# Remove and create the main dir
rimraf outputDir, (err) ->
	fs.mkdirSync(outputDir)

	# Get all imag epaths
	globby ['../static/images/*.jpg'], (err, files) ->
		imgPaths = files

		# Start looping the paths.
		generateImages()