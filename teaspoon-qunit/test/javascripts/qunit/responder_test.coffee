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
      begin: ->
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


test "constructor sets up test callbacks", ->
  sinon.stub(@qunit, "done")
  sinon.stub(@qunit, "moduleStart")
  sinon.stub(@qunit, "moduleDone")
  sinon.stub(@qunit, "testDone")
  sinon.stub(@qunit, "log")

  responder = new Teaspoon.Qunit.Responder(@qunit, @reporter)

  ok(@qunit.done.calledWith(responder.runnerDone), "done hook was established")
  ok(@qunit.moduleStart.calledWith(responder.suiteStarted), "moduleStart hook was established")
  ok(@qunit.moduleDone.calledWith(responder.suiteDone), "moduleDone hook was established")
  ok(@qunit.testDone.calledWith(responder.specDone), "testDone hook was established")
  ok(@qunit.log.calledWith(responder.assertionDone), "log hook was established")


test "constructor reports the runner starting if QUnit version is <= 1.15.0", ->
  sinon.stub(Teaspoon.Qunit, "rawVersion", -> "0.15.0")
  sinon.stub(@qunit, "begin")
  sinon.stub(@reporter, "reportRunnerStarting")

  new Teaspoon.Qunit.Responder(@qunit, @reporter)

  ok(!@qunit.begin.called, "begin hook was not established")
  ok(@reporter.reportRunnerStarting.calledWith(total: null), "reportRunnerStarting was called")

  Teaspoon.Qunit.rawVersion.restore()


test "constructor sets up the begin callback if QUnit version is >= 1.16.0", ->
  sinon.stub(Teaspoon.Qunit, "rawVersion", -> "0.16.0")
  sinon.stub(@qunit, "begin")
  sinon.stub(@reporter, "reportRunnerStarting")

  responder = new Teaspoon.Qunit.Responder(@qunit, @reporter)

  ok(@qunit.begin.calledWith(responder.runnerStarted), "begin hook was established")
  ok(!@reporter.reportRunnerStarting.called, "reportRunnerStarting was not called")

  Teaspoon.Qunit.rawVersion.restore()


test "QUnit.begin reports the runner starting", ->
  sinon.stub(@reporter, "reportRunnerStarting")

  @responder.runnerStarted(@beginDetails)

  ok(@reporter.reportRunnerStarting.calledWith(total: 42), "reportRunnerStarting was called")


test "QUnit.done reports the runner finishing", ->
  sinon.stub(@reporter, "reportRunnerResults")

  @responder.runnerDone(@doneDetails)

  ok(@reporter.reportRunnerResults.calledWith(@doneDetails), "reportRunnerResults was called")


test "QUnit.moduleStart reports the suite starting", ->
  sinon.stub(@reporter, "reportSuiteStarting")

  @responder.suiteStarted(@moduleStartedDetails)

  suiteArg = @reporter.reportSuiteStarting.args[0][0]
  ok(suiteArg instanceof Teaspoon.Qunit.Suite, "a suite instance is passed")
  equal(suiteArg.description, "module1", "the suite has a description")


test "QUnit.moduleDone reports the suite finishing", ->
  sinon.stub(@reporter, "reportSuiteResults")

  @responder.suiteDone(@moduleDoneDetails)

  suiteArg = @reporter.reportSuiteResults.args[0][0]
  ok(suiteArg instanceof Teaspoon.Qunit.Suite, "a suite instance is passed")
  equal(suiteArg.description, "module1", "the suite has a description")


test "QUnit.testDone reports the spec starting and finishing", ->
  sinon.stub(@reporter, "reportSpecStarting")
  sinon.stub(@reporter, "reportSpecResults")

  @responder.specDone(@testDoneDetails)

  specArg = @reporter.reportSpecStarting.args[0][0]
  ok(specArg instanceof Teaspoon.Qunit.Spec, "a test instance is passed")
  ok(/test1/.test(specArg.description), "the test has a description")

  specArg = @reporter.reportSpecResults.args[0][0]
  ok(specArg instanceof Teaspoon.Qunit.Spec, "a test instance is passed")
  ok(/test1/.test(specArg.description), "the test has a description")


test "QUnit.testDone associates accumulated assertions", ->
  sinon.stub(@reporter, "reportSpecResults")

  @responder.assertionDone(@logDetails)
  @responder.specDone(@testDoneDetails)

  specArg = @reporter.reportSpecResults.args[0][0]
  equal(specArg.spec.assertions.length, 1, "reportSpecResults was called with one assertion")
  equal(specArg.spec.assertions[0], @logDetails, "reportSpecResults was called with reported assertions")
