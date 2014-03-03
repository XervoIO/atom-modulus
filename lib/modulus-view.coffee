{EditorView, View} = require 'atom'

librarian = require './librarian'

module.exports =
class ModulusView extends View
  @content: ->
    @div class: 'modulus overlay from-top padded', =>
      @div class: 'inset-panel', =>
        @div class: 'panel-heading', =>
          @span outlet: 'title'
        @div class: 'panel-body padded', =>
          @div outlet: 'projectForm', =>
            @subview 'projectNameEditor', new EditorView(mini:true, placeholderText: 'Project Name')
            @div class: 'pull-right', =>
              @button outlet: 'goButton', class: 'btn btn-primary', 'Go'
          @div outlet: 'progressIndicator', =>
            @span class: 'loading loading-spinner-medium'

  initialize: (serializeState) ->
    console.log 'initialize'
    librarian.init 'api.onmodulus.net', 443, true
    @handleEvents()
    @event = ''
    atom.workspaceView.command 'modulus:start', => @start()
    atom.workspaceView.command 'modulus:stop', => @stop()
    atom.workspaceView.command 'modulus:restart', => @restart()

  serialize: ->

  destroy: ->
    @detach()

  handleEvents: ->
    @goButton.on 'click', => @go()
    @projectNameEditor.on 'core:confirm', => @go()
    @projectNameEditor.on 'core:cancel', => @detach()

  start: ->
    @event = 'start'
    @goButton.text 'Start'
    @title.text 'Start A Project'
    @presentSelf()

  stop: ->
    @event = 'stop'
    @goButton.text 'Stop'
    @title.text 'Stop A Project'
    @presentSelf()

  restart: ->
    @event = 'restart'
    @goButton.text 'Restart'
    @title.text 'Restart A Project'
    @presentSelf()

  presentSelf: ->
    @projectNameEditor.setText ''
    @progressIndicator.hide()
    @projectForm.show()

    atom.workspaceView.append(this)
    @projectNameEditor.focus()

  getUser: (fn) ->
    librarian.user.getForToken atom.config.get('atom-modulus.apiToken'), (err, user) ->
      if err
        return fn(err)
      else
        return fn(null, user)

  getProject: (user, name, fn) ->
    result = null
    librarian.project.find { userId: user.id }, atom.config.get('atom-modulus.apiToken'), (err, projects) ->
      if err
        return fn(err)

      projects.forEach (project) ->
        if project.name.toLowerCase() == name.toLowerCase()
          result = project

      fn(null, result)

  go: ->
    @projectForm.hide()
    @progressIndicator.show()

    @project = @projectNameEditor.getText()
    @getUser (err, user) =>
      @getProject user, @projectNameEditor.getText(), (err, project) =>
        if @event == 'start'
          librarian.project.start project.id, atom.config.get('atom-modulus.apiToken'), =>
            @detach()

        if @event == 'restart'
          librarian.project.restart project.id, atom.config.get('atom-modulus.apiToken'), =>
            @detach()

        if @event == 'stop'
          librarian.project.stop project.id, atom.config.get('atom-modulus.apiToken'), =>
            @detach()
