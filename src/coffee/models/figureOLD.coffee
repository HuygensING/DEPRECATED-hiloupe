
# Model = require 'ampersand-state'
# # xhr = require 'funcky.req'
# # eventEmitter = require '../utils/event-emitter'

# prevTransX = 0
# prevTransY = 0


# class Delta

# 	current: 0
	
# 	set: (prevVal, newVal) ->
# 		prevVal = newVal unless prevVal?

# 		@current = @current + (newVal - prevVal)



# Figure = Model.extend

# 	initialize: ->
# 		@deltaX = new Delta()
# 		@deltaY = new Delta()

# 		@on 'change:scale', @setTransformString
# 		@on 'change:initScale', @setTransformString
# 		@on 'change:translateX', @setTransformString
# 		@on 'change:translateY', @setTransformString
# 		@on 'change:deltaX2', @setTransformStringOnDrag
# 		@on 'change:deltaY2', @setTransformStringOnDrag

# 		@translation =
# 			x: 0
# 			y: 0

# 	session:
# 		translation: 'object'
# 		transformString: 'string'
# 		containerWidth: 'number'
# 		containerHeight: 'number'
# 		containerTop: 'number'
# 		containerLeft: 'number'
# 		initWidth: 'number'
# 		initHeight: 'number'
# 		scale: 'number'
# 		mouseY: 
# 			default: 0
# 			type: 'number'
# 		mouseX:
# 			default: 0
# 			type: 'number'
# 		drag:
# 			default: false
# 			type: 'boolean'
# 		dragMouseX: 
# 			type: 'number'
# 			default: 0
# 		dragMouseY: 
# 			type: 'number'
# 			default: 0

# 	derived:

# 		deltaX2:
# 			deps: ['dragMouseX']
# 			fn: ->
# 				diff = @dragMouseX - @previousAttributes().dragMouseX
# 				diff = 0 unless @dragMouseX? and @previousAttributes().dragMouseX?
# 				diff
# 				# @deltaX.set @previousAttributes().dragMouseX, @dragMouseX

# 		deltaY2:
# 			deps: ['dragMouseY']
# 			fn: ->
# 				diff = @dragMouseY - @previousAttributes().dragMouseY
# 				diff = 0 unless @dragMouseY? and @previousAttributes().dragMouseY?
# 				diff
				
# 				# @deltaY.set @previousAttributes().dragMouseY, @dragMouseY

# 		initSurface:
# 			deps: ['initWidth', 'initHeight']
# 			fn: -> @initWidth * @initHeight

# 		# The figure is either too wide, too high or has exactly the same
# 		# dimensions, because the server always returns a figure, bigger than
# 		# or equal to the container. Scaling up is not an option! ;)
# 		initScale:
# 			deps: ['initWidth', 'initHeight', 'containerWidth', 'containerHeight']
# 			# We only need one scale, because we want to scale proportionally. 
# 			# If the lowest scale is X, than the figure is wider than the container, 
# 			# if Y than higher.
# 			fn: ->
# 				scaleX = @containerWidth / @initWidth
# 				scaleY = @containerHeight / @initHeight

# 				scale = Math.min.call(null, scaleX, scaleY)

# 				+scale.toFixed(2)

# 		# transformString:
# 		# 	deps: ['scale', 'initScale', 'translateX', 'translateY']
# 		# 	fn: ->
# 		# 		scale = @scale ? @initScale

# 		# 		"translate(#{@translateX}px, #{@translateY}px) scale(#{scale}, #{scale})"

# 		width: 
# 			deps: ['scale', 'initScale', 'initWidth']
# 			fn: ->
# 				scale = @scale ? @initScale

# 				scale * @initWidth

# 		height: 
# 			deps: ['scale', 'initScale', 'initHeight']
# 			fn: ->
# 				scale = @scale ? @initScale

# 				scale * @initHeight

# 		surface:
# 			deps: ['width', 'height']
# 			fn: ->
# 				@width * @height

# 		translateX: 
# 			deps: ['containerWidth', 'width']
# 			fn: ->
# 				(@containerWidth/2) - (@width/2)
				
# 		translateY:
# 			deps: ['containerHeight', 'height']
# 			fn: ->
# 				(@containerHeight/2) - (@height/2)

# 		mouseOffsetY:
# 			deps: ['mouseY', 'containerTop']
# 			fn: ->
# 				@mouseY - @containerTop

# 		mouseOffsetX:
# 			deps: ['mouseX', 'containerLeft']
# 			fn: ->
# 				@mouseX - @containerLeft

# 	# CUSTOM METHODS

# 	setTransformString: ->
# 		scale = @scale ? @initScale

# 		@translation.x = @translateX
# 		@translation.y = @translateY

# 		@transformString = "translate(#{@translation.x}px, #{@translation.y}px) scale(#{scale}, #{scale})"
	
# 	setTransformStringOnDrag: ->
# 		scale = @scale ? @initScale

# 		@translation.x += @deltaX2
# 		@translation.y += @deltaY2

# 		@transformString = "translate(#{@translation.x}px, #{@translation.y}px) scale(#{scale}, #{scale})"


# 	zoomIn: (mousePos) ->
# 		@mouseY = mousePos.top
# 		@mouseX = mousePos.left

# 		scale = @scale ? @initScale

# 		newScale = +(scale + 0.1).toFixed(2)
# 		@scale = newScale

# 	zoomOut: (mousePos) ->
# 		@mouseY = mousePos.top
# 		@mouseX = mousePos.left

# 		scale = @scale ? @initScale
		
# 		newScale = +(scale - 0.1).toFixed(2)
		
# 		if newScale < @initScale
# 			newScale = @initScale 	

# 		@scale = newScale 

		



# module.exports = Figure