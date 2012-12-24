#= require qunit-1.10.0
#= require teabag/base/teabag
#= require teabag/qunit/reporters/console
#= require teabag/qunit/reporters/html

class Teabag.Runner extends Teabag.Runner

  env = QUnit
  env.config.autostart = false
  env.config.altertitle = false

  constructor: ->
    super
    env.start()


  setup: ->
    reporter = new (@getReporter())(env)
    reporter.setFilter?(@params["grep"])



class Teabag.Spec

  constructor: (@spec) ->
    @fullDescription = "#{@spec.module} #{@spec.name}"
    @description = @spec.name
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = new Teabag.Suite({description: @spec.module})
    @suiteName = @spec.module
    @viewId = @spec.viewId
    @pending = false


  errors: ->
    return [] if @spec.result
    [{message: @spec.message, stack: @spec.source}]


  getParents: ->
    []


  result: ->
    status = "failed"
    status = "passed" if @spec.result
    status: status
    skipped: false



class Teabag.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.description
    @description = @suite.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = null
    @viewId = null #Math.random() * 200000


  getParent: ->
    null
