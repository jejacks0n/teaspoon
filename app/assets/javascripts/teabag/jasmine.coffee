#= require jasmine-1.3.0
#= require teabag/base/teabag
#= require teabag/jasmine/reporters/html

class Teabag.Runner extends Teabag.Runner

  env = jasmine.getEnv()

  constructor: ->
    super
    env.execute()


  setup: ->
    env.updateInterval = 1000

    # add the spec filter
    if grep = @params["grep"]
      env.specFilter = (spec) -> return spec.getFullName().indexOf(grep) == 0

    # add the reporter and set the filter
    reporter = new (@getReporter())()
    reporter.setFilter?(@params["grep"])
    env.addReporter(reporter)

    # add fixture support
    @addFixtureSupport()


  addFixtureSupport: ->
    return unless jasmine.getFixtures && @fixturePath
    jasmine.getFixtures().containerId = "teabag-fixtures"
    jasmine.getFixtures().fixturesPath = @fixturePath
    jasmine.getStyleFixtures().fixturesPath = @fixturePath
    jasmine.getJSONFixtures().fixturesPath = @fixturePath
