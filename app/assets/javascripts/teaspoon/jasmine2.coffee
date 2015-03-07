#= require teaspoon/base/teaspoon
#= require teaspoon/jasmine2/_namespace
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



class Teaspoon.Spec

  constructor: (@spec) ->
    @fullDescription = @spec.fullName
    @description = @spec.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @spec.parent
    @suiteName = @parent.fullName
    @viewId = @spec.id
    @pending = @spec.status == "pending"


  errors: ->
    return [] unless @spec.failedExpectations.length
    for item in @spec.failedExpectations
      {message: item.message, stack: item.stack}


  getParents: ->
    return @parents if @parents
    @parents ||= []
    parent = @parent
    while parent
      parent = new Teaspoon.Suite(parent)
      @parents.unshift(parent)
      parent = parent.parent
    @parents


  result: ->
    status: @status()
    skipped: @spec.status == "disabled"


  status: ->
    if @spec.status == "disabled" then "passed" else @spec.status



class Teaspoon.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullName
    @description = @suite.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @suite.parent
    @viewId = @suite.id



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
