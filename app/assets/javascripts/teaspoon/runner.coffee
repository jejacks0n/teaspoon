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
      Teaspoon.Reporters[@params["reporter"]]
    else
      if window.navigator.userAgent.match(/PhantomJS/)
        Teaspoon.Reporters.Console
      else
        Teaspoon.Reporters.HTML


  setup: ->
    # left for subclasses to implement
