#= require mocha-1.7.3
#= require ../base/runner
#= require_tree ./reporters

class Teabag.Runner extends Teabag.Runner

  env = mocha.setup("bdd")

  constructor: ->
    super
    env.run()


  setup: ->
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
