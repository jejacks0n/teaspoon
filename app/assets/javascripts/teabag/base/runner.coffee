class Teabag.Runner

  @run: false

  constructor: ->
    return if @constructor.run
    @constructor.run = true
    @fixturePath = "#{Teabag.root}/fixtures"
    @params = Teabag.params = @getParams()
    @setup()


  getParams: ->
    params = {}
    for param in Teabag.location.search.substring(1).split("&")
      [name, value] = param.split("=")
      params[decodeURIComponent(name)] = decodeURIComponent(value)
    params


  getReporter: ->
    if @params["reporter"]
      Teabag.Reporters[@params["reporter"]]
    else
      if window.navigator.userAgent.match(/PhantomJS/)
        Teabag.Reporters.Console
      else
        Teabag.Reporters.HTML


  setup: ->
    # left for subclasses to implement
