#= require angular/angular-scenario-1.0.5
#= require teaspoon/base/teaspoon
#= require teaspoon/angular/reporters/console
#= require teaspoon/angular/reporters/html

class Teaspoon.Runner extends Teaspoon.Runner

  setup: ->
    new (@getReporter())(this)
    angular.scenario.setUpAndRun(scenario_output: "teaspoon,html")



class Teaspoon.Spec

  constructor: (@spec) ->
    @fullDescription = "#{@spec.fullDefinitionName}: #{@spec.name}"
    @description = @spec.name
    @link = "#"
    #@link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = new Teaspoon.Suite(@spec)
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



class Teaspoon.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullDefinitionName
    @description = @suite.fullDefinitionName
    @link = "#"
    @parent = {root: true}
    @viewId = null
