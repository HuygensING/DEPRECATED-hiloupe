Collection = require 'ampersand-collection'
Figure = require '../models/figure'

Figures = Collection.extend
	model: Figure
	mainIndex: 'level'

	initialize: ->
		# prev = "0|"

		# @on 'change:scale', (model, scale) =>
		# 	prevWidth = @active().width
		# 	# console.log model.level, scale, prev
		# 	[prevLevel, prevScale] = prev.split('|')
		# 	# console.log @previous()?, @active().level is +prevLevel, scale < +prevScale, @active().level, +prevLevel, scale, +prevScale
			
		# 	if @previous()? and @active().level is +prevLevel and scale < +prevScale
		# 		console.log +prevLevel, scale, +prevScale
		# 		# console.log 'prev', scale, prevScale
		# 		@active().deactivate()
		# 		@activeIndex -= 1
		# 		@active().activate prevWidth
		# 		prev = "#{@active().level}|#{@active().scale}"
		# 		# console.log 'prev', @active().level

		# 	# console.log prevLevel, @active().level
		# 	if scale > 1 and @next()? and +prevLevel is @active().level
		# 		@active().deactivate()
		# 		@activeIndex += 1
		# 		@active().activate prevWidth
		# 		prev = "#{@active().level}|#{@active().scale}"
		# 		# console.log 'next', @active().level

		@on 'change:scale', (model, value) =>
			if value > 1 and @next()?
				@activeIndex += 1
				@activate model

			if @previous()? and Math.round(model.width) < Math.round(@previous().initWidth)
				@activeIndex -= 1
				@activate model

		@on 'change:left', (model, value) =>
			@each (m) ->
				if model isnt m
					m.set left: value, silent: true

		@on 'change:top', (model, value) =>
			@each (m) ->
				if model isnt m
					m.set top: value, silent: true

		@on 'change:width', (model, value) =>
			@each (m) ->
				if model isnt m
					m.set width: value, silent: true

		@on 'change:height', (model, value) =>
			@each (m) ->
				if model isnt m
					m.set height: value, silent: true

		# @on 'change:mouse', (model, value) =>
		# 	@previous().mousePageX = model.mousePageX
		# 	@previous().mousePageY = model.mousePageY

	activate: (prevLevel) ->
		@each (model, i) =>
			model.deactivate()
		@active().activate prevLevel

	activeIndex: 0
	active: -> 
		@at @activeIndex

	previous: ->
		index = @activeIndex - 1
		@at index

	next: ->
		index = @activeIndex + 1
		@at index

	isFirst: (model) ->
		@indexOf(model) is 0

	isLast: (model) ->
		@indexOf(model) is (@length - 1)

	lastActive: ->
		@isLast @active()

module.exports = Figures