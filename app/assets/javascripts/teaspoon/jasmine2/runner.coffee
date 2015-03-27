class Teaspoon.Jasmine2.Runner extends Teaspoon.Runner

  @setup: ->
    extend = (destination, source) ->
      for property of source
        destination[property] = source[property]
      destination

    window.jasmine = jasmineRequire.core(jasmineRequire)
    env = window.jasmine.getEnv()
    @setupSpecFilter(env)
    extend(window, jasmineRequire.interface(jasmine, env))


  # Jasmine 2 runs the spec filter when the #it block are evaluated. This
  # means we need to set the filter upon page load, instead of when the
  # runner is initialized. Since Jasmine is loaded into the page first, then
  # the tests, then Teaspoon is initialized, this is set up to run early in
  # the boot process.
  @setupSpecFilter: (env) ->
    if grep = Teaspoon.Jasmine2.Runner::getParams()["grep"]
      env.specFilter = (spec) ->
        spec.getFullName().indexOf(grep) == 0


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
