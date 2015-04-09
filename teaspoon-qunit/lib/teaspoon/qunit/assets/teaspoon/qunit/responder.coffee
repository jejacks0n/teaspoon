class Teaspoon.Qunit.Responder

  constructor: (qunit, @reporter) ->
    @reporter.reportRunnerStarting(total: null)

    qunit.done(@runnerDone)
    qunit.moduleStart(@suiteStarted)
    qunit.moduleDone(@suiteDone)
    qunit.testDone(@specDone)
    qunit.log(@assertionDone)

    @assertions = []


  runnerDone: (runner) =>
    @reporter.reportRunnerResults(runner)


  suiteStarted: (suite) =>
    @reporter.reportSuiteStarting(new Teaspoon.Qunit.Suite(suite))


  suiteDone: (suite) =>
    @reporter.reportSuiteResults(new Teaspoon.Qunit.Suite(suite))


  specDone: (spec) =>
    spec.assertions = @assertions
    @assertions = []

    # QUnit doesn't have details about the spec until it's finished. So we
    # wait until it's finished to report that it started.
    spec = new Teaspoon.Qunit.Spec(spec)
    @reporter.reportSpecStarting(spec)
    @reporter.reportSpecResults(spec)


  assertionDone: (assertion) =>
    @assertions.push(assertion)
