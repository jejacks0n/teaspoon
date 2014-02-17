#= require teaspoon/base/teaspoon
#= require teaspoon/qunit/reporters/console
#= require teaspoon/qunit/reporters/html

unless QUnit?
  throw new Teaspoon.Error('QUnit not found -- use `suite.use_framework :qunit` and adjust or remove the `suite.javascripts` directive.')

class Teaspoon.Runner extends Teaspoon.Runner

  constructor: ->
    super
    env.start()


  setup: ->
    new (@getReporter())(env)



class Teaspoon.Spec

  constructor: (@spec) ->
    @fullDescription = "#{@spec.module} #{@spec.name}"
    @description = "#{@spec.name} (#{@spec.failed}, #{@spec.passed}, #{@spec.total})"
    @link = "?grep=#{encodeURIComponent("#{@spec.module}: #{@spec.name}")}"
    @parent = if @spec.module then new Teaspoon.Suite({description: @spec.module}) else null
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



class Teaspoon.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.description
    @description = @suite.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = null


# set the environment
env = QUnit
env.config.autostart = false
env.config.altertitle = false
env.config.filter = Teaspoon.Runner.prototype.getParams()["grep"]

window.fixture = Teaspoon.fixture
originalReset = env.reset
env.reset = ->
  originalReset()
  Teaspoon.fixture.cleanup()
