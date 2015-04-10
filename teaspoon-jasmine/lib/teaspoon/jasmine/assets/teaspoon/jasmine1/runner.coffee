#= require teaspoon/runner

class Teaspoon.Jasmine1.Runner extends Teaspoon.Runner

  constructor: ->
    @env = window.jasmine.getEnv()
    super
    @env.execute()


  setup: ->
    @env.updateInterval = 1000

    # add the spec filter
    if grep = @params["grep"]
      @env.specFilter = (spec) -> spec.getFullName().indexOf(grep) == 0

    # add the reporter
    reporter = new (@getReporter())()
    responder = new Teaspoon.Jasmine1.Responder(reporter)
    @env.addReporter(responder)

    # add fixture support
    @addFixtureSupport()


  addFixtureSupport: ->
    return unless jasmine.getFixtures && @fixturePath
    jasmine.getFixtures().containerId = "teaspoon-fixtures"
    jasmine.getFixtures().fixturesPath = @fixturePath
    jasmine.getStyleFixtures().fixturesPath = @fixturePath
    jasmine.getJSONFixtures().fixturesPath = @fixturePath
