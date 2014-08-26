Model = require 'ampersand-state'

Test = Model.extend
	props:
		prop1: 'number'
		prop2: 'string'

	session:
		prop3: 'number'

	derived:
		prop4:
			deps: ['prop1']
			fn: ->
				console.log 'called prop4'
		prop5:
			deps: ['prop2']
			fn: ->
				console.log 'called prop5'
		prop6:
			deps: ['prop3']
			fn: ->
				console.log 'called prop6'

module.exports = Test