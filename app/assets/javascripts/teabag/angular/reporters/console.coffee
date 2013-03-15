class Teabag.Reporters.Console extends Teabag.Reporters.Console
  constructor: () ->
    super
    angular.scenario.output 'teabag', (_context, _runner, model) =>
      model.on 'RunnerBegin', =>
        @reportRunnerStarting(total: angular.scenario.Describe.specId)

      model.on 'SpecEnd', (spec) =>
        @reportSpecResults(spec)

      model.on 'RunnerEnd', =>
        @reportRunnerResults()

