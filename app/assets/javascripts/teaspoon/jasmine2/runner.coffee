class Teaspoon.Jasmine2.Runner extends Teaspoon.Runner

  constructor: ->
    @env = window.jasmine.getEnv()
    super
    @env.execute()


  setup: ->
    # add the responder
    reporter = new (@getReporter())()
    responder = new Teaspoon.Jasmine2.Responder(reporter)
    @env.addReporter(responder)

    # add fixture support
    @addFixtureSupport()


  addFixtureSupport: ->
    return unless jasmine.getFixtures && @fixturePath
    jasmine.getFixtures().containerId = "teaspoon-fixtures"
    jasmine.getFixtures().fixturesPath = @fixturePath
    jasmine.getStyleFixtures().fixturesPath = @fixturePath
    jasmine.getJSONFixtures().fixturesPath = @fixturePath


# Shim since core initializes the base class
# TODO: register the runner to use with core
class Teaspoon.Runner
  constructor: -> new Teaspoon.Jasmine2.Runner
