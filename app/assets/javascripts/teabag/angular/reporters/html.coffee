class Teabag.Reporters.HTML extends Teabag.Reporters.HTML
  constructor: (runner) ->
    super
    angular.scenario.output 'teabag', (_context, _runner, model) =>
      model.on 'RunnerBegin', =>
        @reportRunnerStarting(total: angular.scenario.Describe.specId)
        header = document.getElementById('header')
        header.parentNode.removeChild(header) if header
        specs = document.getElementById('specs')
        specs.style.paddingTop = 0 if specs

      model.on 'Specbegin', (spec) =>
        @reportSpecStarting(spec)

      model.on 'SpecEnd', (spec) =>
        @reportSpecResults(spec)

      model.on 'RunnerEnd', =>
        @reportRunnerResults()

  envInfo: ->
    "angular-scenario 1.0.5"

