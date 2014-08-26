Model = require 'ampersand-state'

Figure = Model.extend

	loadImageParts: ->
		width = @initWidth*@scale
		height = @initHeight*@scale

		visibleArea =
			left: -1 * @left
			top: -1 * @top
			right: (-1 * @left) + @containerWidth
			bottom: (-1 * @top) + @containerHeight

		partSize = 240*@scale

		horMin = Math.min((visibleArea.right - visibleArea.left), width)
		verMin = Math.min((visibleArea.bottom - visibleArea.top), height)
		
		firstVisibleRow = Math.floor(visibleArea.top/partSize)
		firstVisibleRow = 0 if firstVisibleRow < 0

		lastVisibleRow = firstVisibleRow + Math.ceil(verMin/partSize)
		
		firstVisibleColumn = Math.floor(visibleArea.left/partSize)
		firstVisibleColumn = 0 if firstVisibleColumn < 0

		lastVisibleColumn = firstVisibleColumn + Math.ceil(horMin/partSize)

		lastVisibleColumn = @sources[0].length - 1 if lastVisibleColumn > @sources[0].length - 1
		lastVisibleRow = @sources.length - 1 if lastVisibleRow > @sources.length - 1

		for row in [firstVisibleRow..lastVisibleRow]
			for column in [firstVisibleColumn..lastVisibleColumn]
				el = document.getElementById "id-#{@level}-#{column}-#{row}"
				
				# console.log el.src
				# loadme = ->
				# 	@style.opacity = 1
				# 	@removeEventListener 'load', loadme
				
				# el.addEventListener 'load', loadme
					


				el.src = @sources[row][column]

	initialize: ->
		@on 'change:left', (model, value, options) =>
			@el.style.left = "#{value}px"

		@on 'change:top', (model, value, options) =>
			@el.style.top = "#{value}px"    

		@on 'change:scale', (model, scale) =>
			# Set the new scale to the element.
			@el.style.transform = "scale(#{scale})"

			@width = @initWidth * scale
			@height = @initHeight * scale

			previousScale = model.previousAttributes().scale

			if previousScale?
				currentWidth = @initWidth * scale
				previousWidth = @initWidth * previousScale
				offsetLeft = (previousWidth - currentWidth)/2

				@left += Math.round offsetLeft

				currentHeight = @initHeight * scale
				previousHeight = @initHeight * previousScale
				offsetTop = (previousHeight - currentHeight)/2
				
				@top += Math.round offsetTop

		@on 'change:mouse', (model, value) ->
			if value?
				@loadImageParts()

	session:
		el: 'object'
		level: 'number'
		sources: 'array'
		mousePageX: 'number'
		mousePageY: 'number'
		drag: 
			type: 'boolean'
			default: false
		dragOffset: 'object'
		containerWidth: 
			type: 'number'
			setOnce: true
		containerHeight: 
			type: 'number'
			setOnce: true
		containerTop: 
			type: 'number'
			setOnce: true
		containerLeft: 
			type: 'number'
			setOnce: true
		initWidth: 
			type: 'number'
			default: 0
			setOnce: true
		initHeight: 
			type: 'number'
			default: 0
			setOnce: true
		left: 
			type: 'number'
			default: 0
		top: 
			type: 'number'
			default: 0
		scaleLevel:
			type: 'number'
			default: 0
		first: 'boolean'
		last: 'boolean'
		scale: 'number'
		width: 'number'
		height: 'number'

	derived:
		# Move to onChange.
		mouse:
			deps: ['mousePageX', 'mousePageY']
			fn: ->
				if @drag
					@left = @mousePageX - @dragOffset.x
					@top = @mousePageY - @dragOffset.y

					@mousePageX + @mousePageY

		# The figure is either too wide, too high or has exactly the same
		# dimensions, because the server always returns a figure, bigger than
		# or equal to the container. Scaling up is not an option! ;)
		initScale:
			deps: ['initWidth', 'initHeight', 'containerWidth', 'containerHeight']
			# We only need one scale, because we want to scale proportionally. 
			# If the lowest scale is X, than the figure is wider than the container, 
			# if Y than higher.
			fn: ->
				# Only calculate the scale if both the initWidth and initHeight are known.
				if @initWidth > 0 and @initHeight > 0
					scaleX = @containerWidth / @initWidth
					scaleY = @containerHeight / @initHeight

					# console.log @containerWidth, @containerHeight
					# console.log 'x', @initWidth, scaleX
					# console.log 'y', @initHeight, scaleY

					scale = Math.min.call(null, scaleX, scaleY)

					# console.log @initWidth, scale, scale*@initWidth, scale*@initHeight

					scale = 1 if scale > 1

					scale



		# width:
		# 	deps: ['initWidth', 'scale']
		# 	fn: ->
		# 		@initWidth*@scale

		# height:
		# 	deps: ['initHeight', 'scale']
		# 	fn: ->
		# 		@initHeight*@scale

		scaleStep:
			deps: ['scaleLevel']
			fn: ->
				@scaleLevel/10

	activate: (prevLevel) ->
		if prevLevel?
			@scale = prevLevel.width/@initWidth
			@left = prevLevel.left
			@top = prevLevel.top
		else
			@scale = @initScale
			@left = Math.round (@containerWidth - (@initWidth * @scale))/2
			@top = Math.round (@containerHeight - (@initHeight * @scale))/2

		# @el.style.transform = "scale(#{@scale})"

		@loadImageParts()

		@el.classList.add 'active'

	deactivate: ->
		@el.classList.remove 'active'

	startDrag: (ev) ->
		@drag = true

		@dragOffset =
			x: ev.pageX - @left
			y: ev.pageY - @top

	zoomIn: ->
		if @scale < 1
			@scale += 0.05
			# @scale = 1 if @scale > 1

	zoomOut: ->
		if @scale > @initScale
			@scale -= 0.05
			@scale = @initScale if @scale < @initScale


module.exports = Figure