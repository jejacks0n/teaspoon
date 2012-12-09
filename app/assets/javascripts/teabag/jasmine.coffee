#= require jasmine-1.3.0
#= require_self
#= require_tree ./reporters/jasmine

class @Teabag
  @defer: false
  @finished: false
  executed = false

  env = jasmine.getEnv()

  @execute: (@fixturePath = null) ->
    if @defer && !executed
      @defer = false
      return
    executed = true
    @setup()
    env.execute()


  @setup: ->
    env.updateInterval = 1000

    # add the reporter
    if navigator.userAgent.match(/PhantomJS/)
      reporter = new Teabag.Reporters.Console()
    else
      reporter = new Teabag.Reporters.HTML()
    env.addReporter(reporter)

    # add the spec filter
    params = {}
    for param in window.location.search.substring(1).split("&")
      [name, value] = param.split("=")
      params[decodeURIComponent(name)] = decodeURIComponent(value)
    if params["grep"] then env.specFilter = (spec) ->
      return spec.getFullName().indexOf(params["grep"]) == 0

    # add fixture support
    return unless jasmine.getFixtures
    jasmine.getFixtures().containerId = "teabag-fixtures"
    jasmine.getFixtures().fixturesPath = @fixturePath
    jasmine.getStyleFixtures().fixturesPath = @fixturePath
    jasmine.getJSONFixtures().fixturesPath = @fixturePath


Teabag.Reporters = {}
