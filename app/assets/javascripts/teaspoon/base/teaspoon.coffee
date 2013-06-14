#= require_self
#= require teaspoon/base/runner
#= require teaspoon/base/fixture
#= require teaspoon/base/reporters/html
#= require teaspoon/base/reporters/console

class @Teaspoon
  @defer:     false
  @slow:      75
  @root:      null
  @started:   false
  @finished:  false
  @Reporters: {}
  @Date:      Date
  @location:  window.location
  @messages:  []

  @execute: ->
    if @defer
      @defer = false
      return
    @started = true
    new Teaspoon.Runner()

  @onWindowLoad: (method) ->
    originalOnload = window.onload
    window.onload = ->
      originalOnload() if originalOnload && originalOnload.call
      method()

  # provides interface for AMD usage -- pass all dependencies in as an array, and params will be checked for matches
  @resolveDependenciesFromParams: (all = []) ->
    deps = []
    return all if (paths = @location.search.match(/[\?&]file(\[\])?=[^&\?]*/gi)) == null

    for path in paths
      parts = decodeURIComponent(path.replace(/\+/g, " ")).match(/\/(.+)\.(js|js.coffee|coffee)$/i)
      continue if parts == null
      file = parts[1].substr(parts[1].lastIndexOf("/") + 1)
      for dep in all then deps.push(dep) if dep.indexOf(file) >= 0
    deps


  # logging methods -- used by selenium / phantomJS to get information back to ruby
  @log: ->
    @messages.push(arguments[0])
    try console.log(arguments...)
    catch e
      throw new Error("Unable to use console.log for logging")


  @getMessages: ->
    messages = @messages
    @messages = []
    messages
