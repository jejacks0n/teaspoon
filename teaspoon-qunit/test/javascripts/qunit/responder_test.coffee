module "Teaspoon.Qunit.Responder",
  setup: ->
    @beginDetails =
      totalTests: 42
    @doneDetails =
      failed: 20
      passed: 22
      total: 42
      runtime: 999
    @moduleStartedDetails =
      name: "module1"
    @moduleDoneDetails =
      name: "module1"
      failed: 20
      passed: 22
      total: 42
      runtime: 999
    @testStartedDetails =
      name: "test1"
      module: "module1"
    @testDoneDetails =
      name: "test1"
      module: "module1"
      failed: 20
      passed: 22
      total: 42
      runtime: 999
    @logDetails =
      name: "test1"
      module: "module1"
      result: true
      message: "1 == 1"

    @qunit =
      done: ->
      moduleStart: ->
      moduleDone: ->
      testStart: ->
      testDone: ->
      log: ->
    @reporter =
      reportRunnerStarting: ->
      reportRunnerResults: ->
      reportSuiteStarting: ->
      reportSuiteResults: ->
      reportSpecStarting: ->
      reportSpecResults: ->
    @responder = new Teaspoon.Qunit.Responder(@qunit, @reporter)


test "constructor reports the runner starting", 1, ->
  sinon.spy(@reporter, "reportRunnerStarting")

  new Teaspoon.Qunit.Responder(@qunit, @reporter)

  ok(@reporter.reportRunnerStarting.calledWith(total: null), "reportRunnerStarting was called")


test "constructor sets up test callbacks", 5, ->
  sinon.spy(@qunit, "done")
  sinon.spy(@qunit, "moduleStart")
  sinon.spy(@qunit, "moduleDone")
  sinon.spy(@qunit, "testDone")
  sinon.spy(@qunit, "log")

  responder = new Teaspoon.Qunit.Responder(@qunit, @reporter)

  ok(@qunit.done.calledWith(responder.runnerDone), "done hook was established")
  ok(@qunit.moduleStart.calledWith(responder.suiteStarted), "moduleStart hook was established")
  ok(@qunit.moduleDone.calledWith(responder.suiteDone), "moduleDone hook was established")
  ok(@qunit.testDone.calledWith(responder.specDone), "testDone hook was established")
  ok(@qunit.log.calledWith(responder.assertionDone), "log hook was established")


test "QUnit.done reports the runner finishing", 1, ->
  sinon.spy(@reporter, "reportRunnerResults")

  @responder.runnerDone(@doneDetails)

  ok(@reporter.reportRunnerResults.calledWith(@doneDetails), "reportRunnerResults was called")


test "QUnit.moduleStart reports the suite starting", 1, ->
  sinon.spy(@reporter, "reportSuiteStarting")

  @responder.suiteStarted(@moduleStartedDetails)

  ok(@reporter.reportSuiteStarting.calledWith(@moduleStartedDetails), "reportSuiteStarting was called")


test "QUnit.moduleDone reports the suite finishing", 1, ->
  sinon.spy(@reporter, "reportSuiteResults")

  @responder.suiteDone(@moduleDoneDetails)

  ok(@reporter.reportSuiteResults.calledWith(@moduleDoneDetails), "reportSuiteResults was called")


test "QUnit.testDone reports the spec starting and finishing", 2, ->
  sinon.spy(@reporter, "reportSpecStarting")
  sinon.spy(@reporter, "reportSpecResults")

  @responder.specDone(@testDoneDetails)

  ok(@reporter.reportSpecStarting.calledWith(@testDoneDetails), "reportSpecStarting was called")
  ok(@reporter.reportSpecResults.calledWith(@testDoneDetails), "reportSpecResults was called")


test "QUnit.testDone associates accumulated assertions", 1, ->
  sinon.spy(@reporter, "reportSpecResults")

  @responder.assertionDone(@logDetails)
  @responder.specDone(@testDoneDetails)

  doneDetails = @testDoneDetails
  doneDetails.assertions = [@logDetails]

  ok(@reporter.reportSpecResults.calledWith(doneDetails), "reportSpecResults was called with assertions")
