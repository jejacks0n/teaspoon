#= require mocha-1.7.3
#= require teabag/base/teabag
#= require_tree ./mocha/reporters

class Teabag.Runner extends Teabag.Runner

  env = mocha.setup("bdd")

  constructor: ->
    super
    env.run()


  setup: ->
    # add the reporter and set the filter
    if navigator.userAgent.match(/PhantomJS/)
      reporter = Teabag.Reporters.Console
    else
      reporter = Teabag.Reporters.HTML
    reporter.filter = @params["grep"]
    env.setup(reporter: reporter)
