class Teaspoon.Reporters.HTML extends Teaspoon.Reporters.HTML

  constructor: (runner) ->
    super
    @reportRunnerStarting(runner)
    runner.on("fail", @reportSpecResults)
    runner.on("test end", @reportSpecResults)
    runner.on("end", @reportRunnerResults)


  reportSpecResults: (spec, err) =>
    if err
      spec.err = err
      @reportSpecResults(spec) if spec.type == "hook"
      return
    @reportSpecStarting(spec)
    super


  envInfo: ->
    "mocha #{_mocha_version || "[unknown version]"}"


class Teaspoon.Reporters.HTML.SpecView extends Teaspoon.Reporters.HTML.SpecView

  updateState: (state) ->
    super(state, @spec.spec.duration)
