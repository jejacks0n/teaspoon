#= require_self
#= require_tree ./mixins
#= require teaspoon/utility
#= require teaspoon/runner
#= require teaspoon/fixture
#= require teaspoon/hook
#= require teaspoon/spec
#= require teaspoon/suite
#= require teaspoon/reporters/html
#= require teaspoon/reporters/console

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
    unless Teaspoon.framework
      throw "No framework registered. Expected a framework to register itself, but nothing has."

    if Teaspoon.defer
      Teaspoon.defer = false
      return
    Teaspoon.reload() if Teaspoon.started
    Teaspoon.started = true
    new (Teaspoon.resolveClass("Runner"))()


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
    try console?.log?(arguments...)
    catch e
      throw new Error("Unable to use console.log for logging")


  @getMessages: ->
    messages = Teaspoon.messages
    Teaspoon.messages = []
    messages


  @setFramework: (namespace) ->
    Teaspoon.framework = namespace
    window.fixture = Teaspoon.resolveClass("Fixture")


  # This checks if a framework has overridden a core class and if we should
  # load that instead of the core base class.
  @resolveClass: (klass) ->
    if framework_override = Teaspoon.checkNamespace(Teaspoon.framework, klass)
      return framework_override
    else if teaspoon_core = Teaspoon.checkNamespace(Teaspoon, klass)
      return teaspoon_core

    throw "Could not find the class you're looking for: #{klass}"


  @checkNamespace: (root, klass) ->
    namespaces = klass.split('.')
    scope = root

    for namespace, i in namespaces
      return false if !(scope = scope[namespace])

    return scope
