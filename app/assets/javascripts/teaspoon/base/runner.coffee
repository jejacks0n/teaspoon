class Teaspoon.Runner

  @run: false

  constructor: ->
    return if @constructor.run
    @constructor.run = true
    @fixturePath = "#{Teaspoon.root}/fixtures"
    @setup()


  getReporter: ->
    if Teaspoon.params["reporter"]
      Teaspoon.Reporters[Teaspoon.params["reporter"]]
    else
      if window.navigator.userAgent.match(/PhantomJS/)
        Teaspoon.Reporters.Console
      else
        Teaspoon.Reporters.HTML


  setup: ->
    # left for subclasses to implement
