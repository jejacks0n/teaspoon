class Teaspoon.Mocha.Responder

  constructor: (runner) ->
    @reporter.reportRunnerStarting(total: runner.total)

    runner.on("end", @runnerDone)
    runner.on("suite", @suiteStarted)
    runner.on("suite end", @suiteDone)
    runner.on("test", @specStarted)
    runner.on("pass", @specPassed)
    runner.on("fail", @specFailed)


  runnerDone: =>
    @reporter.reportRunnerResults()


  suiteStarted: (suite) =>
    @reporter.reportSuiteStarting()


  suiteDone: (suite) =>
    @reporter.reportSuiteResults()


  specStarted: (spec) =>
    @reporter.reportSpecStarting(spec)


  specPassed: (spec) =>
    @reporter.reportSpecResults(spec)


  specFailed: (specOrHook, err) =>
    specOrHook.err = err

    @reporter.reportSpecResults(specOrHook)
