Model = require 'ampersand-state'
# xhr = require 'funcky.req'
# eventEmitter = require '../utils/event-emitter'

Container = Model.extend
  session:
    width: 'number'
    height: 'number'

  derived:
    surface:
      deps: ['width', 'height']
      fn: -> @width * @height



module.exports = Container