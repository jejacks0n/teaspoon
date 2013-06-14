class Teaspoon.Reporters.Console extends Teaspoon.Reporters.Console

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
    super
