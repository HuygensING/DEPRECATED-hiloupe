App = require './views/main'

document.addEventListener 'DOMContentLoaded', ->
	container = document.querySelector('.container')

	app = new App
		parent: container
		imgPath: 'SK-C-5.jpg'
		debug: true

	container.appendChild app.el