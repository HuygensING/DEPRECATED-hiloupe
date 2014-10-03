funckyReq = require 'funcky.req'
funckyEl = require('funcky.el').el

Levels = require '../collections/levels'
Level = require '../models/level'
Container = require '../models/container'

View = require 'ampersand-view'
LevelView = require './level'

Main = View.extend

	# @param parent (el) the parent of hiloupe. Needed for calcing the size.
	# @param imgPath (str) the path of the img.
	# @param debug (bool) show debug div.
	initialize: (@options={}) ->
		throw new ReferenceError('[HiLoupe] @options.imgPath missing!') unless @options.imgPath?

		@options.debug ?= false

		@collection = new Levels()

		req = funckyReq.get "#{@options.imgPath}/metadata.json"
		req.done (xhr) =>
			data = JSON.parse(xhr.response)
			
			@renderLevels data

		window.addEventListener 'resize', =>
			box = funckyEl(@parent).boundingBox()
			@collection.each (level) -> level.set container: box

		@render()

	renderLevels: (data) ->
		containerBox = funckyEl(@parent).boundingBox()

		data.levels.forEach (levelData, levelNo) =>
			if containerBox.width > containerBox.height
				fit = containerBox.height < levelData.height
			else
				fit = containerBox.width < levelData.width

			if fit
				level = new Level
					imgPath: @options.imgPath
					partSize: data.partSize
					level: levelNo
					container: containerBox
					initWidth: levelData.width
					initHeight: levelData.height

				@collection.add level

		@renderCollection @collection, LevelView, @el

		@collection.active().active = true

	render: ->
		@el = document.createElement 'div'
		@el.className = "hiloupe"

		if @options.debug
			@collection.on 'change:scale', @renderDebug.bind(@)

			div = document.createElement 'div'
			div.id = 'debug'

			@el.appendChild div

		@

	renderDebug: (model, value) ->
		debug = document.getElementById('debug')
		html = "active level: #{@collection.active().level} of #{@collection.length - 1}<br>"
		@collection.each (model) ->
			html += "
				<h4>Level #{model.level}</h4>
				<ul>
					<li><label>width</label><span>#{model.width}</span></li>
					<li><label>height</label><span>#{model.height}</span></li>
					<li><label>top</label><span>#{model.top}</span></li>
					<li><label>left</label><span>#{model.left}</span></li>
					<li><label>scale</label><span>#{model.scale}</span></li>
				</ul>"
		debug.innerHTML = html


module.exports = Main