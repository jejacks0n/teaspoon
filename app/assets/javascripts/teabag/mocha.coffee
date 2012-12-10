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
    # add the spec filter
    params = {}
    for param in window.location.search.substring(1).split("&")
      [name, value] = param.split("=")
      params[decodeURIComponent(name)] = decodeURIComponent(value)

    # add the reporter and set the filter
    if navigator.userAgent.match(/PhantomJS/)
      reporter = Teabag.Reporters.Console
    else
      reporter = Teabag.Reporters.HTML
    reporter.filter = params["grep"]
    env.setup(reporter: reporter)
