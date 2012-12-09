#= require mocha-1.7.3
#= require_self
#= require ./reporters/base
#= require_tree ./reporters/mocha

class @Teabag
  @defer: false
  @finished: false
  @slow: 75
  @fixturePath = null
  @Reporters = {}
  executed = false

  env = mocha.setup("bdd")

  @execute: () ->
    if @defer && !executed
      @defer = false
      return
    executed = true
    @setup()
    env.run()


  @setup: ->
    # add the reporter
    if navigator.userAgent.match(/PhantomJS/)
      reporter = Teabag.Reporters.Console
    else
      reporter = "html" # Teabag.Reporters.HTML
    env.setup(reporter: reporter)
