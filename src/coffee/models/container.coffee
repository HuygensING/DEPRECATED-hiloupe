Model = require 'ampersand-state'

Container = Model.extend

  session:
    width: 'number'
    height: 'number'
    top: 'number'
    left: 'number'
    bottom: 'number'
    right: 'number'

  derived:
    surface:
      deps: ['width', 'height']
      fn: ->
      	@width * @height



module.exports = Container