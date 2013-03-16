class Teabag.Reporters.HTML extends Teabag.Reporters.HTML

  constructor: ->
    super
    angular.scenario.output("teabag", @bindScenarioOutput)


  bindScenarioOutput: (context, runner, model) =>
    model.on "Specbegin", (spec) => @reportSpecStarting(spec)
    model.on "SpecEnd", (spec) => @reportSpecResults(spec)
    model.on "RunnerEnd", => @reportRunnerResults()
    model.on "RunnerBegin", =>
      @reportRunnerStarting(total: angular.scenario.Describe.specId)
      header = document.getElementById("header")
      header.parentNode.removeChild(header) if header
      specs = document.getElementById("specs")
      specs.style.paddingTop = 0 if specs


  envInfo: ->
    "angular-scenario 1.0.5"
