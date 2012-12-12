class Teabag.Runner

  @run: false

  constructor: ->
    return if @constructor.run
    @constructor.run = true
    @fixturePath = Teabag.fixturePath
    @params = @getParams()
    @setup()


  getParams: ->
    params = {}
    for param in Teabag.location.search.substring(1).split("&")
      [name, value] = param.split("=")
      params[decodeURIComponent(name)] = decodeURIComponent(value)
    params


  setup: ->
    # left for subclasses to implement
