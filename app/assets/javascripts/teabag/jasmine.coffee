#= require jasmine-1.3.0
#= require_self
#= require ./reporters/base
#= require_tree ./reporters/jasmine

class @Teabag
  @defer: false
  @finished: false
  @slow: 75
  @fixturePath = null
  @Reporters = {}
  executed = false

  env = jasmine.getEnv()

  @execute: () ->
    if @defer && !executed
      @defer = false
      return
    executed = true
    @setup()
    env.execute()


  @setup: ->
    env.updateInterval = 1000

    # add the spec filter
    params = {}
    for param in window.location.search.substring(1).split("&")
      [name, value] = param.split("=")
      params[decodeURIComponent(name)] = decodeURIComponent(value)
    if params["grep"]
      env.specFilter = (spec) -> return spec.getFullName().indexOf(params["grep"]) == 0

    # add the reporter
    if navigator.userAgent.match(/PhantomJS/)
      reporter = new Teabag.Reporters.Console()
    else
      reporter = new Teabag.Reporters.HTML(params["grep"])
    env.addReporter(reporter)

    # add fixture support
    return unless jasmine.getFixtures && Teabag.fixturePath
    jasmine.getFixtures().containerId = "teabag-fixtures"
    jasmine.getFixtures().fixturesPath = Teabag.fixturePath
    jasmine.getStyleFixtures().fixturesPath = Teabag.fixturePath
    jasmine.getJSONFixtures().fixturesPath = Teabag.fixturePath
