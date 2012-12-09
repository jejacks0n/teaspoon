class Teabag.Reporters.Console extends Teabag.ConsoleReporterBase

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
    @log(type: "spec", status: status, description: spec.title, suite: spec.parent.fullTitle())


  reportRunnerResults: =>
    @log(type: "results", total: @total, failures: @fails, elapsed: ((Date.now() - @start) / 1000).toFixed(5))
    Teabag.finished = true


  trackFailure: (spec) ->
    @fails.push(spec: spec.fullTitle(), description: spec.err.message, link: "?grep=#{encodeURIComponent(spec.getFullName())}", trace: spec.err.stack || spec.err.toString())
