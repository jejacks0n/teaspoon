#= require qunit-1.10.0
#= require teabag/base/teabag
#= require teabag/qunit/reporters/console
#= require teabag/qunit/reporters/html

class Teabag.Runner extends Teabag.Runner

  constructor: ->
    super
    env.start()


  setup: ->
    reporter = new (@getReporter())(env)
    reporter.setFilter?(@params)



class Teabag.Spec

  constructor: (@spec) ->
    @fullDescription = "#{@spec.module} #{@spec.name}"
    @description = "#{@spec.name} (#{@spec.failed}, #{@spec.passed}, #{@spec.total})"
    @link = "?grep=#{encodeURIComponent("#{@spec.module}: #{@spec.name}")}"
    @parent = if @spec.module then new Teabag.Suite({description: @spec.module}) else null
    @suiteName = @spec.module
    @viewId = @spec.viewId
    @pending = false


  errors: ->
    return [] unless @spec.failed
    for item in @spec.assertions
      continue if item.result
      {message: item.message, stack: item.source}


  getParents: ->
    return [] unless @parent
    [@parent]


  result: ->
    status = "failed"
    status = "passed" unless @spec.failed
    status: status
    skipped: false



class Teabag.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.description
    @description = @suite.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = null


# set the environment
env = QUnit
env.config.autostart = false
env.config.altertitle = false
env.config.filter = Teabag.Runner.prototype.getParams()["grep"]

window.fixture = Teabag.fixture
originalReset = env.reset
env.reset = ->
  originalReset()
  Teabag.fixture.cleanup()
