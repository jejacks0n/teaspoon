#= require angular-scenario-1.0.5
#= require teabag/base/teabag
#= require teabag/angular/reporters/console
#= require teabag/angular/reporters/html

class Teabag.Runner extends Teabag.Runner

  setup: ->
    new (@getReporter())(this)
    angular.scenario.setUpAndRun(scenario_output: "teabag,html")



class Teabag.Spec

  constructor: (@spec) ->
    @fullDescription = "#{@spec.fullDefinitionName}: #{@spec.name}"
    @description = @spec.name
    @link = "#"
    #@link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = new Teabag.Suite(@spec)
    @suiteName = @parent.fullDescription
    @viewId = @spec.id
    @pending = false


  getParents: ->
    [@parent]


  errors: ->
    return [] unless @spec.steps
    for step in @spec.steps
      continue if step.status == "success"
      {message: step.error, stack: [step.line]}


  result: ->
    status = "failed"
    status = "passed" if @spec.status == "success"
    status: status
    skipped: false



class Teabag.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullDefinitionName
    @description = @suite.fullDefinitionName
    @link = "#"
    @parent = {root: true}
    @viewId = null
