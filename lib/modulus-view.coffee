{EditorView, View} = require 'atom'

librarian = require './librarian'

module.exports =
  class ModulusView extends View
    @content: ->
      @div class: 'modulus overlay from-top padded', =>
        @div class: 'inset panel', =>
          @div class: 'panel-heading', =>
            @span outlet: 'title'
        @div class: 'panel-body padded', =>
          @div outlet: 'projectForm', =>
            @subview 'projectNameEditor', new EditorView(mini:true, placeholderText: 'Project Name')
            @div class: 'pull-right', =>
              @button outlet: 'goButton', class: 'btn btn-primary', 'Go'

    initialize: (serializeState) ->
      @handleEvents()
      @event = ''
      atom.workspaceView.command "modulus:start", => @start()
      atom.workspaceView.command "modulus:stop", => @stop()
      atom.workspaceView.command "modulus:restart", => @restart()

    serialize: ->

    destroy: ->
      @detach()

    handleEvents: ->
      @goButton.on 'click', => @go

    start: ->
      @event = 'start'
      @title.text 'Start A Project'
      @presentSelf()

    stop: ->
      @event = 'stop'
      @title.text 'Stop A Project'
      @presentSelf()

    restart: ->
      @event = 'restart'
      @title.text 'Restart A Project'
      @presentSelf()

    presentSelf: ->
      @projectForm.show()

      atom.workspaceView.append(this)
      @projectNameEditor.focus()

    getUser: (fn) ->
      librarian.user.getForToken atom.config.get('modulus.apiToken'), (err, user) ->
        if err
          return fn(err)
        else
          return fn(null, user)

    go: ->
      @project = @projectNameEditor.getText()
      getUser (err, user) =>
        # TODO: run the selected command.
