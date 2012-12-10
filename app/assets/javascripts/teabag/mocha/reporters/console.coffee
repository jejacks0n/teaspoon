class Teabag.Reporters.Console extends Teabag.Reporters.Console

  constructor: (runner) ->
    super
    runner.on("fail", @reportSpecResults)
    runner.on("test end", @reportSpecResults)
    runner.on("end", @reportRunnerResults)


  reportSpecResults: (spec, err) =>
    if err
      spec.err = err
      return
    super


  resultForSpec: (spec) ->
    skipped: spec.state == "skipped"
    passed: spec.state == "passed"


  trackFailure: (spec) ->
    @fails.push(spec: spec.fullTitle(), description: spec.err.message, link: @paramsFor(spec.fullTitle()), trace: spec.err.stack || spec.err.toString())
