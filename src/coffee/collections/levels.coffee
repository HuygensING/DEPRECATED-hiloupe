Collection = require 'ampersand-collection'
Level = require '../models/level'

Levels = Collection.extend
	model: Level
	mainIndex: 'level'

	initialize: ->
		@on 'change:scale', (currentLevel, value) =>
			if value > 1 and @next()?
				@activateNext()

			if @previous()? and Math.round(currentLevel.width) < Math.round(@previous().initWidth)
				@activatePrevious()

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

	activateNext: ->
		currentLevel = @active()
		@activeIndex += 1
		nextLevel = @active()
		@copyGeometry currentLevel, nextLevel

		currentLevel.active = false
		nextLevel.active = true

	activatePrevious: ->
		currentLevel = @active()
		@activeIndex -= 1
		previousLevel = @active()
		@copyGeometry currentLevel, previousLevel

		currentLevel.active = false
		previousLevel.active = true

	copyGeometry: (currentLevel, nextLevel) ->
		nextLevel.set
			scale: currentLevel.width/nextLevel.initWidth
			left: currentLevel.left
			top: currentLevel.top
			width: currentLevel.width
			height: currentLevel.height
		,
			silent: true

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

module.exports = Levels