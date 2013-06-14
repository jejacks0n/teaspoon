class Teaspoon.Reporters.Console extends Teaspoon.Reporters.Console

  constructor: ->
    super
    angular.scenario.output("teaspoon", @bindScenarioOutput)


  bindScenarioOutput: (context, runner, model) =>
    model.on "runnerBegin", => @reportRunnerStarting(total: angular.scenario.Describe.specId)
    model.on "specEnd", (spec) => @reportSpecResults(spec)
    model.on "runnerEnd", => @reportRunnerResults()
