#= require teaspoon/base/teaspoon
#= require teaspoon/jasmine2/_namespace
#= require teaspoon/jasmine2/spec
#= require teaspoon/jasmine2/suite
#= require teaspoon/jasmine2/responder
#= require teaspoon/jasmine2/reporters/console
#= require teaspoon/jasmine2/reporters/html

unless jasmineRequire?
  throw new Teaspoon.Error('Jasmine 2 not found -- use `suite.use_framework :jasmine` and adjust or remove the `suite.javascripts` directive.')

class Teaspoon.Runner extends Teaspoon.Runner

  # Jasmine 2 runs the spec filter when the #it block are evaluated. This
  # means we need to set the filter upon page load, instead of when the
  # runner is initialized. Since Jasmine is loaded into the page first, then
  # the tests, then Teaspoon is initialized, this is set up to run early in
  # the boot process.
  @setupSpecFilter: (env) ->
    if grep = Teaspoon.Runner::getParams()["grep"]
      env.specFilter = (spec) ->
        spec.getFullName().indexOf(grep) == 0


  constructor: ->
    super
    env.execute()


  setup: ->
    # add the responder
    reporter = new (@getReporter())()
    responder = new Teaspoon.Jasmine2.Responder(reporter)
    env.addReporter(responder)

    # add fixture support
    @addFixtureSupport()


  addFixtureSupport: ->
    return unless jasmine.getFixtures && @fixturePath
    jasmine.getFixtures().containerId = "teaspoon-fixtures"
    jasmine.getFixtures().fixturesPath = @fixturePath
    jasmine.getStyleFixtures().fixturesPath = @fixturePath
    jasmine.getJSONFixtures().fixturesPath = @fixturePath



class Teaspoon.fixture extends Teaspoon.fixture

  window.fixture = @

  @load: ->
    args = arguments
    env.beforeEach => fixture.__super__.constructor.load.apply(@, args)
    env.afterEach => @cleanup()
    super

  @set: ->
    args = arguments
    env.beforeEach => fixture.__super__.constructor.set.apply(@, args)
    env.afterEach => @cleanup()
    super


extend = (destination, source) ->
  for property of source
    destination[property] = source[property]
  destination

# set the environment
window.jasmine = jasmineRequire.core(jasmineRequire)
env = window.jasmine.getEnv()
Teaspoon.Runner.setupSpecFilter(env)
jasmineInterface = jasmineRequire.interface(jasmine, env)
extend(window, jasmineInterface)
