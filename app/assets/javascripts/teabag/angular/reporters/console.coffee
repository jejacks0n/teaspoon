class Teabag.Reporters.Console extends Teabag.Reporters.Console

  constructor: ->
    super
    angular.scenario.output("teabag", @bindScenarioOutput)


  bindScenarioOutput: (context, runner, model) =>
    model.on "runnerBegin", => @reportRunnerStarting(total: angular.scenario.Describe.specId)
    model.on "specEnd", (spec) => @reportSpecResults(spec)
    model.on "runnerEnd", => @reportRunnerResults()
