React = require 'react'

App = require './views/app'

document.addEventListener 'DOMContentLoaded', ->
    React.renderComponent <App />, document.body