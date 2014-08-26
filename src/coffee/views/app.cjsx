React = require 'react'
funcky = require 'funcky.req'
funckyEl = require('funcky.el').el
Figures = require '../collections/figures'
Figure = require '../models/figure'

Test = require '../models/test'

App = React.createClass

	getInitialState: ->
		level: 0
		data: []

	componentDidMount: ->
		containerStyle = window.getComputedStyle(@getDOMNode())
		
		@containerWidth = +containerStyle.width.slice(0, -2)
		@containerHeight = +containerStyle.height.slice(0, -2)

		data = JSON.stringify
			id: 'big'
			containerWidth: @containerWidth
			containerHeight: @containerHeight
			level: 0

		req = funcky.post 'hiloupe/init', data: data

		req.done (res) =>
			@setState
				data: JSON.parse(res.response).data

			@addListeners()

	componentDidUpdate: ->
		test = new Test
			prop1: 10
			prop2: '11'
			prop3: 12

		# test.prop1 = 13


		left = funckyEl(@getDOMNode()).position().left
		top = funckyEl(@getDOMNode()).position().top

		@figures = new Figures()

		updateDebug = (model) =>
			debug = document.getElementById('debug')
			html = "active level: #{@figures.active().level} of #{@figures.length - 1}<br>"
			@figures.each (model) ->
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

		@figures.on 'change:scale', (model, value) => updateDebug model
		@figures.on 'change:mouse', (model, value) => updateDebug model
			

		for level, i in @state.data
			@figures.add new Figure
				first: i is 0
				last: @state.data.length is (i + 1)
				sources: level.sources
				level: i
				el: @getDOMNode().querySelector("figure[data-level=\"#{i}\"]")
				containerWidth: @containerWidth
				containerHeight: @containerHeight
				containerLeft: left
				containerTop: top
				initWidth: level.width
				initHeight: level.height

		setTimeout (=>
			@figures.active().activate()
		), 0

	render: ->
		levels = @state.data.map (level, levelNo) =>
			images = level.sources.map (column, columnNo) =>
				row = column.map (src, rowNo) =>
					src = '/images/blank.gif' # if levelNo > @state.level
					id = "id-#{levelNo}-#{rowNo}-#{columnNo}"
					<img src={src} draggable="false" id={id} />

				<div className="row">
					{row}
				</div>

			<figure data-level={levelNo}>
				{images}
			</figure>

		<div className="hiloupe">
			{levels}
			<div id="debug"></div>
		</div>

	# CUSTOM METHODS

	handleMousewheel: (ev) ->
		zoomMethod = if ev.wheelDeltaY > 0 then 'zoomIn' else 'zoomOut'

		@figures.active()[zoomMethod]()
		# @figures.each (figure) ->
		# 	figure[zoomMethod]()

	addListeners: ->
		@getDOMNode().addEventListener 'mousewheel', @handleMousewheel

		@getDOMNode().addEventListener 'mousedown', (ev) =>
			@figures.active().startDrag ev

		@getDOMNode().addEventListener 'mousemove', (ev) =>
			@figures.active().mousePageX = ev.pageX
			@figures.active().mousePageY = ev.pageY

		@getDOMNode().addEventListener 'mouseup', => 
			@figures.active().drag = false

module.exports = App