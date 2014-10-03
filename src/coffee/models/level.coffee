Model = require 'ampersand-state'
Container = require './container'

Level = Model.extend

	loadImageParts: ->
		width = @initWidth*@scale
		height = @initHeight*@scale

		visibleArea =
			left: -1 * @left
			top: -1 * @top
			right: (-1 * @left) + @container.width
			bottom: (-1 * @top) + @container.height

		partSize = 240*@scale

		horMin = Math.min((visibleArea.right - visibleArea.left), width)
		verMin = Math.min((visibleArea.bottom - visibleArea.top), height)
		
		firstVisibleRow = Math.floor(visibleArea.top/partSize)
		firstVisibleRow = 0 if firstVisibleRow < 0

		lastVisibleRow = firstVisibleRow + Math.ceil(verMin/partSize)
		
		firstVisibleColumn = Math.floor(visibleArea.left/partSize)
		firstVisibleColumn = 0 if firstVisibleColumn < 0

		lastVisibleColumn = firstVisibleColumn + Math.ceil(horMin/partSize)

		lastVisibleColumn = @columns - 1 if lastVisibleColumn > @columns - 1
		lastVisibleRow = @rows - 1 if lastVisibleRow > @rows - 1

		for row in [firstVisibleRow..lastVisibleRow]
			for column in [firstVisibleColumn..lastVisibleColumn]
				el = document.getElementById @getImgId row, column

				y = row * @partSize
				x = column * @partSize

				try
					el.src = "#{@imgPath}/#{@boxSize}/#{x}-#{y}.jpg"
				catch error
					console.log "#{@imgPath}/#{@boxSize}/#{x}-#{y}.jpg | #{error}"

	initialize: ->
		@on 'change:container.height', (model, value) =>
			@loadImageParts() if @active

		@on 'change:container.width', (model, value) =>
			@loadImageParts() if @active

		@on 'change:scale', (model, value) =>
			@width = Math.round(@initWidth * value)
			@height = Math.round(@initHeight * value)

			previousScale = model.previousAttributes().scale

			if previousScale?
				# Absolute top and left of the image
				absTop = @container.top + @top
				absLeft = @container.left + @left

				relZoomPositionY = @zoomPosition.y - absTop
				relZoomPositionX = @zoomPosition.x - absLeft

				scaleDiff = (@scale/previousScale)

				zoomOffsetY = relZoomPositionY - (scaleDiff * relZoomPositionY)
				zoomOffsetX = relZoomPositionX - (scaleDiff * relZoomPositionX)

				@top = Math.round @top + zoomOffsetY
				@left = Math.round @left + zoomOffsetX
			else
				@left = Math.round (@container.width - (@width))/2
				@top = Math.ceil((@container.height - (@height))/2)

			@boxTopLeft()

		@on 'change:active', (model, value) =>
			if value
				unless @scale
					@scale = @initScale
					
				@loadImageParts()

	session:
		zoomPosition: 
			type: 'object'
			default: ->
				x: 0
				y: 0
		active: 'boolean'
		level: 'number'
		imgPaths: 'array'
		imgPath: 'string'
		drag: 'object'
		# container: 'object'
		partSize: 'number'
		initWidth: 
			type: 'number'
			default: 0
		initHeight: 
			type: 'number'
			default: 0
		left: 
			type: 'number'
			default: 0
		top: 
			type: 'number'
			default: 0
		scale: 'number'
		width: 'number'
		height: 'number'

	children:
		container: Container

	derived:
		# The figure is either too wide, too high or has exactly the same
		# dimensions, because the server always returns a figure, bigger than
		# or equal to the container. Scaling up is not an option! ;)
		initScale:
			deps: ['initWidth', 'initHeight', 'container.height', 'container.width']
			# We only need one scale, because we want to scale proportionally. 
			# If the lowest scale is X, than the figure is wider than the container, 
			# if Y than higher.
			fn: ->
				# Only calculate the scale if both the initWidth and initHeight are known.
				if @initWidth > 0 and @initHeight > 0
					scaleX = @container.width / @initWidth
					scaleY = @container.height / @initHeight

					scale = Math.min.call(null, scaleX, scaleY)

					scale = 1 if scale > 1

					scale

		columns:
			deps: ['initWidth', 'partSize']
			fn: ->
				Math.ceil @initWidth/@partSize

		rows:
			deps: ['initHeight', 'partSize']
			fn: ->
				Math.ceil @initHeight/@partSize

		boxSize:
			deps: ['initWidth', 'initHeight']
			fn: ->
				Math.max @initWidth, @initHeight

	zoomIn: (pageX, pageY) ->
		# console.log 'zoomin'
		@zoomPosition =
			x: pageX
			y: pageY

		if @scale < 1
			@scale += 0.05

	zoomOut: (pageX, pageY) ->
		# console.log 'zoomout'
		@zoomPosition =
			x: pageX
			y: pageY

		if @scale > @initScale
			scale = @scale -= 0.05
			scale = @initScale if scale < @initScale
			@scale = scale

	startDrag: (pageX, pageY) ->
		@drag =
			x: pageX - @left
			y: pageY - @top

	mouseMove: (pageX, pageY) ->
		if @drag?
			@left = pageX - @drag.x
			@top = pageY - @drag.y

			@boxTopLeft()

			@loadImageParts()

	stopDrag: ->
		@drag = null

	boxTopLeft: ->
		if @height > @container.height
			if @top > 0
				@top = 0
			else if @top + @height < @container.height
				@top = @container.height - @height
		else
			if @top < 0
				@top = 0
			else if @top > @container.height - @height
				@top = @container.height - @height
		
		if @width > @container.width 
			if @left > 0
				@left = 0
			else if @left + @width < @container.width
				@left = @container.width - @width
		else
			if @left < 0
				@left = 0
			else if @left > @container.width - @width
				@left = @container.width - @width

	getImgId: (row, column) ->
		"id-#{@level}-#{row*@partSize}-#{column*@partSize}"

module.exports = Level