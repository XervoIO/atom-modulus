request = require('request')

Q = require('q')

projectList = []

module.exports =

  getProjectList: (userId, apiToken, fn) ->

    deferred = Q.defer()

    url = 'https://api.onmodulus.net/user/' + userId + '/projects?authToken=' + apiToken

    unless projectList.legnth == 0

      request url, (error, response, body) ->

        if error

          return deferred.reject(error)

        if not error and response.statusCode is 200

          projectList = JSON.parse(body)

          deferred.resolve(projectList)

    else

      deferred.resolve(projectList)

    return deferred.promise.nodeify(fn)

  findProjectId: (userId, apiToken, projectName, fn) ->

    deferred = Q.defer()

    @getProjectList(userId, apiToken).then (projects) ->

      for project in projects

        if project.name == projectName

          deferred.resolve(project.id)

      deferred.reject("Project Not Found")

    return deferred.promise.nodeify(fn)

  start: (userId, apiToken, projectName, fn) ->

    deferred = Q.defer()

    @findProjectId(userId, apiToken, projectName).then (projectId) ->

      url = 'https://api.onmodulus.net/project/' + projectId + '/start?authToken=' + apiToken

      request url, (error, response, body) ->

        if error

          return deferred.reject(error)

        if not error and response.statusCode is 200

          deferred.resolve(response)

    return deferred.promise.nodeify(fn)

  stop: (userId, apiToken, projectName, fn) ->

    deferred = Q.defer()

    @findProjectId(userId, apiToken, projectName).then (projectId) ->

      url = 'https://api.onmodulus.net/project/' + projectId + '/stop?authToken=' + apiToken

      request url, (error, response, body) ->

        if error

          return deferred.reject(error)

        if not error and response.statusCode is 200

          deferred.resolve(response)

    return deferred.promise.nodeify(fn)
