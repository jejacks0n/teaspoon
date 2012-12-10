class Teabag.Reporters.Console extends Teabag.Reporters.Console

  constructor: (runner) ->
    super
    runner.on("fail", @reportSpecResults)
    runner.on("test end", @reportSpecResults)
    runner.on("end", @reportRunnerResults)


  reportSpecResults: (spec, err) =>
    switch spec.state
      when "passed" then status = "pass"
      when "pending" then status = "skipped"
      else
        return unless err
        spec.err = err
        @trackFailure(spec)
        status = "fail"
    @total += 1
    @log(type: "spec", status: status, description: spec.title)


  trackFailure: (spec) ->
    @fails.push(spec: spec.fullTitle(), description: spec.err.message, link: @paramsFor(spec.fullTitle()), trace: spec.err.stack || spec.err.toString())
