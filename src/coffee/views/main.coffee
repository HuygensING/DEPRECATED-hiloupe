funckyReq = require 'funcky.req'
funckyEl = require('funcky.el').el

Levels = require '../collections/levels'
Level = require '../models/level'
Container = require '../models/container'

View = require 'ampersand-view'
LevelView = require './level'

Main = View.extend
	initialize: (@options) ->
		@options.debug ?= false

		@collection = new Levels()

		@containerBox = funckyEl(@parent).boundingBox()

		data = JSON.stringify
			imgPath: @options.imgPath
			containerWidth: @containerBox.width
			containerHeight: @containerBox.height
			level: 0

		req = funckyReq.post 'hiloupe/init', data: data

		req.done (res) =>
			data = JSON.parse(res.response).data
			
			@renderLevels data

			@collection.active().active = true

		window.addEventListener 'resize', =>
			box = funckyEl(@parent).boundingBox()
			# @container.set box
			@collection.each (level) -> level.set container: box


		@render()

	renderLevels: (data) ->		
		data.forEach (levelData, levelNo) =>
			level = new Level
				imgPaths: levelData.sources
				level: levelNo
				container: @containerBox
				initWidth: levelData.width
				initHeight: levelData.height

			@collection.add level

		@renderCollection @collection, LevelView, @el

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
