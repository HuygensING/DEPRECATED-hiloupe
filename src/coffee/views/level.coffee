View = require 'ampersand-view'

Level = View.extend
	initialize: ->
		@model.on 'change:left', (model, value, options) =>
			@el.style.left = "#{value}px"

		@model.on 'change:top', (model, value, options) =>
			@el.style.top = "#{value}px"

		@model.on 'change:scale', (model, scale) =>
			@el.style.transform = "scale(#{scale})"

		@model.on 'change:active', (model, value) =>
			func = if value then 'add' else 'remove'
			@el.classList[func] 'active'

			if value
				@el.style.transform = "scale(#{model.scale})"

		@model.on 'change:visible', (model, value) =>
			func = if value then 'add' else 'remove'
			@el.classList[func] 'visible'

		# @model.on 'activated', (model) =>
		# 	@el.style.transform = "scale(#{model.scale})"
		# 	@el.style.left = "#{model.left}px"
		# 	@el.style.top = "#{model.top}px"

	render: ->
		@el = document.createElement 'figure'
		@el.setAttribute 'data-level', @model.level

		@model.imgPaths.forEach (column, columnNo) =>
			div = document.createElement 'div'
			div.className = 'row'

			column.forEach (row, rowNo) =>
				img = document.createElement 'img'
				img.id = "id-#{@model.level}-#{rowNo}-#{columnNo}"
				img.setAttribute 'draggable', false
				img.src = "images/blank.gif"

				div.appendChild img

			@el.appendChild div

		@

	events:
		'mousewheel': 'onMouseWheel'
		'mouseup': 'onMouseUp'
		'mousemove': 'onMouseMove'
		'mousedown': 'onMouseDown'
		'gesturechange': -> console.log arguments

	onMouseWheel: (ev) ->
		func = if ev.wheelDeltaY > 0 then 'zoomIn' else 'zoomOut'
		@model[func] ev.pageX, ev.pageY

	onMouseDown: (ev) ->
		# Store the mouse offset in the @drag property.
		@model.startDrag ev.pageX, ev.pageY

	onMouseMove: (ev) ->
		@model.mouseMove ev.pageX, ev.pageY

	onMouseUp: ->
		@model.stopDrag()


module.exports = Level
