ModulusView = require './modulus-view'

module.exports =
  modulusView: null

  activate: (state) ->
    @modulusView = new ModulusView(state.gistViewState)

  deactivate: ->
    @modulusView.destroy()

  serialize: ->
    modulusViewState: @modulusView.serialize()

  configDefaults:
    ApiToken: ''
