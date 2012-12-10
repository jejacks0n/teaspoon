#= require jasmine-1.3.0
#= require ../base/runner
#= require_tree ./reporters

class Teabag.Runner extends Teabag.Runner

  env = jasmine.getEnv()

  constructor: ->
    super
    env.execute()


  setup: ->
    env.updateInterval = 1000

    # add the spec filter
    params = {}
    for param in window.location.search.substring(1).split("&")
      [name, value] = param.split("=")
      params[decodeURIComponent(name)] = decodeURIComponent(value)
    if params["grep"]
      env.specFilter = (spec) -> return spec.getFullName().indexOf(params["grep"]) == 0

    # add the reporter and set the filter
    if navigator.userAgent.match(/PhantomJS/)
      reporter = new Teabag.Reporters.Console()
    else
      reporter = new Teabag.Reporters.HTML()
    reporter.setFilter(params["grep"])
    env.addReporter(reporter)

    # add fixture support
    return unless jasmine.getFixtures && @fixturePath
    jasmine.getFixtures().containerId = "teabag-fixtures"
    jasmine.getFixtures().fixturesPath = @fixturePath
    jasmine.getStyleFixtures().fixturesPath = @fixturePath
    jasmine.getJSONFixtures().fixturesPath = @fixturePath
