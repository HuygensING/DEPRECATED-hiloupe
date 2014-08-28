fs = require 'fs'
path = require 'path'
util = require 'util'
gm = require 'gm'
async = require 'async'
EventEmitter = require('events').EventEmitter


class Generator extends EventEmitter

	constructor: (baseDir, imgPath, partSize=240) ->
		@partSize = partSize

		if baseDir? and imgPath?
			@generate baseDir, imgPath

	generate: (baseDir, imgPath) ->
		# Create the output dir. Name of the dir is the basename of the image.
		id = path.basename(imgPath, path.extname(imgPath))
		outputDir = "#{baseDir}/#{id}"
		fs.mkdirSync outputDir

		@getImgSize imgPath, (width, height) =>
			# Get the sizes of the images at different levels.
			sizes = @getSizes width, height

			@writeBaseImages outputDir, imgPath, sizes, =>
				@writeParts outputDir, sizes, width, height, =>
					console.log "DONE! #{outputDir}"
					@emit 'done'
			
	writeParts: (outputDir, boxSizes, width, height, done) ->
		write = (boxSize, cb) =>
			fs.mkdirSync("#{outputDir}/#{boxSize}")

			boxDim = @boxSizeDimensions boxSize, width, height

			rows = Math.ceil(boxDim.height/@partSize)
			columns = Math.ceil(boxDim.width/@partSize)

			# console.log boxSize, rows, columns

			async.eachSeries [0...columns], ((column, columnDone) =>
				async.eachSeries [0...rows], ((row, rowDone) =>
					y = row * @partSize
					x = column * @partSize

					outputPath = "#{outputDir}/#{boxSize}/#{x}-#{y}.jpg"
					
					gm("#{outputDir}/#{boxSize}.jpg")
						.options(imageMagick: true)
						.resize(boxSize, boxSize)
						.crop(@partSize, @partSize, x, y)
						.setFormat('jpeg')
						.quality(90)
						.write(outputPath, (err) ->
							return console.log err if err
							console.log "Written: #{outputPath}"
							rowDone()
						)

				), -> columnDone()
			), ->  cb()

		async.eachSeries boxSizes, write, done

	writeBaseImages: (outputDir, imgPath, boxSizes, done) ->
		write = (boxSize, cb) =>
			gm(imgPath)
				.options(imageMagick: true)
				.resize(boxSize, boxSize)
				.write("#{outputDir}/#{boxSize}.jpg", (err) ->
					return console.log err if err?
					console.log "Written BASE: #{outputDir}/#{boxSize}.jpg"
					cb())

		async.eachSeries boxSizes, write, done
		

	# @param {int} width - Width of the original image.
	# @param {int} height - Height of the original image.
	# @return {array} sizes - The size of the image at different levels. The array key is the level and the value the box size.
	getSizes: (width, height) ->
		i = 0
		boxSize = @partSize
		boxSizes = []
		nextBoxSize = => (@partSize*i*i) + @partSize
		originalBoxSize = Math.max(width, height)

		while boxSize < originalBoxSize
			boxSizes.push boxSize
			i = i + 1
			boxSize = nextBoxSize()

		# Remove the last boxSize and replace with the original images' boxSize
		boxSizes.pop()
		boxSizes.push originalBoxSize
		boxSizes

	# @param {String} imgPath - The path to the original image.
	# @param {Function} done - Callback.
	getImgSize: (imgPath, done) ->
		gm(imgPath)
			.options(imageMagick: true)
			.size (err, value) =>
				return console.log err if err?

				done value.width, value.height

	boxSizeDimensions: (boxSize, originalWidth, originalHeight) ->
		# Calc the ratio between the original width and the width at a level.
		ratio = boxSize/Math.max(originalWidth, originalHeight)

		# Calc the height and width at that level.
		width: Math.round ratio * originalWidth
		height: Math.round ratio * originalHeight

module.exports = Generator