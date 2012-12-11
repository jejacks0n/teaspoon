class Teabag.Reporters.Console extends Teabag.Reporters.Console

  constructor: (runner) ->
    super
    runner.on("fail", @reportSpecResults)
    runner.on("test end", @reportSpecResults)
    runner.on("end", @reportRunnerResults)


  reportSpecResults: (@spec, err) =>
    if err
      @spec.err = err
      return
    super
