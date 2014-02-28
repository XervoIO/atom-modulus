
path = require('path')

request = require('request')

modulusApi = require('./modulus-api')

module.exports =

  configDefaults:
    ApiToken: ""
    UserId: ""

  activate: (state) ->

    atom.workspaceView.command "modulus:start", => @start()

    atom.workspaceView.command "modulus:stop", => @stop()

  getProjectName: ->

    projectPath = atom.project.getPath()

    packagejson = require(atom.project.getPath() + '/package.json')

    if packagejson["mod-project-name"]

      return packagejson["mod-project-name"]

    else

      throw Error('No mod project name')

  start: ->

    modulusApi.start(atom.config.get('modulus.UserId'), atom.config.get('modulus.ApiToken'), @.getProjectName())

  stop: ->

    modulusApi.stop(atom.config.get('modulus.UserId'), atom.config.get('modulus.ApiToken'), @.getProjectName())
