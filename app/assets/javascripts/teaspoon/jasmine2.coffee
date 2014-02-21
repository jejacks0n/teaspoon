
#= require teaspoon/base/teaspoon
#= require teaspoon/jasmine2/reporters/html
#= require teaspoon/jasmine2/reporters/console

unless jasmine?
  throw new Teaspoon.Error('Jasmine not found -- use `suite.use_framework :jasmine` and adjust or remove the `suite.javascripts` directive.')

class Teaspoon.Runner extends Teaspoon.Runner

  constructor: ->
    super
    env.execute()


  setup: ->
    # add the reporter
    reporter = new (@getReporter())()
    env.addReporter(reporter)

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
    @parent = @spec.suite
    @suiteName = @parent.fullName
    @viewId = @spec.viewId
    @pending = @spec.status == "pending"


  errors: ->
    for item in @spec.failedExpectations
      continue if item.passed
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
    status: @spec.status
    skipped: @spec.status == "disabled"



class Teaspoon.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullName
    @description = @suite.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @suite.parent
    @viewId = @suite.viewId



class Teaspoon.fixture extends Teaspoon.fixture

  window.fixture = @

  @load: ->
    args = arguments
    throw "Teaspoon can't load fixtures outside of describe." unless env.currentSuite || env.currentSpec
    if env.currentSuite
      env.beforeEach => fixture.__super__.constructor.load.apply(@, args)
      env.afterEach => @cleanup()
      super
    else
      env.currentSpec.after => @cleanup()
      super


  @set: ->
    args = arguments
    throw "Teaspoon can't load fixtures outside of describe." unless env.currentSuite || env.currentSpec
    if env.currentSuite
      env.beforeEach => fixture.__super__.constructor.set.apply(@, args)
      env.afterEach => @cleanup()
      super
    else
      env.currentSpec.after => @cleanup()
      super



# set the environment
env = jasmine.getEnv()
if grep = Teaspoon.params["grep"]
  env.specFilter = (spec) -> spec.getFullName().indexOf(grep) == 0
