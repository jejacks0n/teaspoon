#= require teaspoon/base/teaspoon
#= require teaspoon/jasmine/reporters/html

unless jasmine?
  throw new Teaspoon.Error('Jasmine not found -- use `suite.use_framework :jasmine` and adjust or remove the `suite.javascripts` directive.')

class Teaspoon.Runner extends Teaspoon.Runner

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
    @fullDescription = @spec.getFullName()
    @description = @spec.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @spec.suite
    @suiteName = @parent.getFullName()
    @viewId = @spec.viewId
    @pending = @spec.pending


  errors: ->
    return [] unless @spec.results
    for item in @spec.results().getItems()
      continue if item.passed()
      {message: item.message, stack: item.trace.stack}


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
    results = @spec.results()
    status = "failed"
    status = "passed" if results.passed()
    status = "pending" if @spec.pending
    status: status
    skipped: results.skipped



class Teaspoon.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.getFullName()
    @description = @suite.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @suite.parentSuite
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
