# Copyright (c) 2014 Modulus
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
    librarian.user.getForToken atom.config.get('modulus.apiToken'), (err, user) ->
      if err
        return fn(err)
      else
        return fn(null, user)

  getProject: (user, name, fn) ->
    result = null
    librarian.project.find { userId: user.id }, atom.config.get('modulus.apiToken'), (err, projects) ->
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
      if err
        return @detach()

      @getProject user, @projectNameEditor.getText(), (err, project) =>
        if err or project is null
          return @detach()

        if @event == 'start'
          librarian.project.start project.id, atom.config.get('modulus.apiToken'), =>
            @detach()

        if @event == 'restart'
          librarian.project.restart project.id, atom.config.get('modulus.apiToken'), =>
            @detach()

        if @event == 'stop'
          librarian.project.stop project.id, atom.config.get('modulus.apiToken'), =>
            @detach()
