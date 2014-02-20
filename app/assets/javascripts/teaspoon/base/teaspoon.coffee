#= require_self
#= require teaspoon/base/runner
#= require teaspoon/base/fixture
#= require teaspoon/base/hook
#= require teaspoon/base/reporters/html
#= require teaspoon/base/reporters/console

class @Teaspoon
  @defer:     false
  @slow:      75
  @root:      window.location.pathname.replace(/\/+(index\.html)?$/, "").replace(/\/[^\/]*$/, "")
  @started:   false
  @finished:  false
  @Reporters: {}
  @Date:      Date
  @location:  window.location
  @messages:  []

  @execute: ->
    if Teaspoon.defer
      Teaspoon.defer = false
      return
    Teaspoon.reload() if Teaspoon.started
    Teaspoon.started = true
    new Teaspoon.Runner()


  @reload: ->
    window.location.reload()


  @onWindowLoad: (method) ->
    originalOnload = window.onload
    window.onload = ->
      originalOnload() if originalOnload && originalOnload.call
      method()


  @resolveDependenciesFromParams: (all = []) ->
    deps = []
    return all if (paths = Teaspoon.location.search.match(/[\?&]file(\[\])?=[^&\?]*/gi)) == null

    for path in paths
      parts = decodeURIComponent(path.replace(/\+/g, " ")).match(/\/(.+)\.(js|js.coffee|coffee)$/i)
      continue if parts == null
      file = parts[1].substr(parts[1].lastIndexOf("/") + 1)
      for dep in all then deps.push(dep) if dep.indexOf(file) >= 0
    deps


  @log: ->
    Teaspoon.messages.push(arguments[0])
    try console.log(arguments...)
    catch e
      throw new Error("Unable to use console.log for logging")


  @getMessages: ->
    messages = Teaspoon.messages
    Teaspoon.messages = []
    messages



class Teaspoon.Error extends Error

  constructor: (message) ->
    @name = "TeaspoonError"
    @message = (message || "")
