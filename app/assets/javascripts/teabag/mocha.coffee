#= require mocha-1.7.3
#= require_self
#= require_tree ./reporters/mocha

class @Teabag
  @defer: false
  @finished: false
  executed = false

  env = mocha.setup("bdd")

  @execute: (@fixturePath = null) ->
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


Teabag.Reporters = {}
