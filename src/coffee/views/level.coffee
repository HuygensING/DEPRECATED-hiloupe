View = require 'ampersand-view'

Level = View.extend
	initialize: ->
		@model.on 'change:left', (model, value, options) =>
			@el.style.left = "#{value}px"

		@model.on 'change:top', (model, value, options) =>
			@el.style.top = "#{value}px"

		@model.on 'change:scale', (model, scale) =>
			@el.style.transform = "scale(#{scale})"

			# iPad compatible.
			@el.style.WebkitTransform = "scale(#{scale})"

		@model.on 'change:active', (model, value) =>
			func = if value then 'add' else 'remove'
			@el.classList[func] 'active'

			if value
				@el.style.transform = "scale(#{model.scale})"

		@model.on 'change:visible', (model, value) =>
			func = if value then 'add' else 'remove'
			@el.classList[func] 'visible'

	render: ->
		@el = document.createElement 'figure'
		@el.setAttribute 'data-level', @model.level

		for row in [0...@model.rows]
			div = document.createElement 'div'
			div.className = 'row'

			for column in [0...@model.columns]
				img = document.createElement 'img'
				img.id = @model.getImgId(row, column)
				img.setAttribute 'draggable', false
				img.src = "/images/blank.gif"

				div.appendChild img


			@el.appendChild div

		@boundTouchStart = @onTouchStart.bind(@)
		@boundTouchMove = @onTouchMove.bind(@)
		@boundTouchEnd = @onTouchEnd.bind(@)
		@boundGestureChange = @onGestureChange.bind(@)
		@el.addEventListener 'touchstart', @boundTouchStart
		@el.addEventListener 'touchmove', @boundTouchMove
		@el.addEventListener 'touchend', @boundTouchEnd
		@el.addEventListener 'gesturechange', @boundGestureChange

		@

	events:
		'mousewheel': 'onMouseWheel'
		'mouseup': 'onMouseUp'
		'mousemove': 'onMouseMove'
		'mousedown': 'onMouseDown'

	onMouseWheel: (ev) ->
		func = if ev.wheelDeltaY > 0 then 'zoomIn' else 'zoomOut'
		@model[func] ev.pageX, ev.pageY

	onMouseDown: (ev) ->
		# Store the mouse offset in the @drag property.
		@model.startDrag ev.pageX, ev.pageY

	onMouseMove: (ev) ->
		@model.mouseMove ev.pageX, ev.pageY

	onMouseUp: (ev) ->
		@model.stopDrag()

	onTouchStart: (ev) ->
		@model.startDrag ev.pageX, ev.pageY

	onTouchMove: (ev) ->
		@model.mouseMove ev.pageX, ev.pageY

	onTouchEnd: (ev) ->
		@model.stopDrag()

	onGestureChange: (ev) ->
		ev.preventDefault()

		if ev.scale < 1.0
			func = 'zoomIn'
		else if ev.scale > 1.0
			func = 'zoomOut'

		@model[func] ev.pageX, ev.pageY

	remove: ->
		@el.removeEventListener 'touchstart', @boundTouchStart
		@el.removeEventListener 'touchmove', @boundTouchMove
		@el.removeEventListener 'touchend', @boundTouchEnd
		@el.removeEventListener 'gesturechange', @boundGestureChange

		@stopListening()
		
		if @el.parentNode?
			@el.parentNode.removeChild @el

module.exports = Level