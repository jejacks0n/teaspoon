class Teaspoon.Mocha.Responder

  constructor: (runner) ->
    @reporter.reportRunnerStarting(total: runner.total)

    runner.on("end", @runnerDone)
    runner.on("suite", @suiteStarted)
    runner.on("suite end", @suiteDone)
    runner.on("test", @specStarted)
    runner.on("fail", @specFailed)
    runner.on("test end", @specFinished)


  runnerDone: =>
    @reporter.reportRunnerResults()


  suiteStarted: (suite) =>
    @reporter.reportSuiteStarting(new Teaspoon.Mocha.Suite(suite))


  suiteDone: (suite) =>
    @reporter.reportSuiteResults(new Teaspoon.Mocha.Suite(suite))


  specStarted: (spec) =>
    @reporter.reportSpecStarting(new Teaspoon.Mocha.Spec(spec))


  specFinished: (spec) =>
    spec = new Teaspoon.Mocha.Spec(spec)
    @reporter.reportSpecResults(spec) unless spec.result().status == "failed"


  specFailed: (spec, err) =>
    spec.err = err

    @reporter.reportSpecResults(new Teaspoon.Mocha.Spec(spec))
