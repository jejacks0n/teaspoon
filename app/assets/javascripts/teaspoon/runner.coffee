class Teaspoon.Runner

  @run: false

  constructor: ->
    return if @constructor.run
    @constructor.run = true
    @fixturePath = "#{Teaspoon.root}/fixtures"
    @params = Teaspoon.params = @getParams()
    @setup()


  getParams: ->
    params = {}
    for param in Teaspoon.location.search.substring(1).split("&")
      [name, value] = param.split("=")
      params[decodeURIComponent(name)] = decodeURIComponent(value)
    params


  getReporter: ->
    if @params["reporter"]
      @findReporter(@params["reporter"])
    else
      if window.navigator.userAgent.match(/PhantomJS/)
        @findReporter("Console")
      else
        @findReporter("HTML")


  setup: ->
    # left for subclasses to implement


  findReporter: (type) ->
    Teaspoon.resolveClass("Reporters.#{type}")
