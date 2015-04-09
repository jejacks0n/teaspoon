module "Teaspoon.Qunit.Runner",
  setup: ->
    QUnit.start = sinon.spy()
    Teaspoon.Qunit.Runner.prototype.reportRunnerStarting = sinon.spy()

test "constructor tells QUnit to start", 1, ->
  new Teaspoon.Qunit.Runner()
  ok(QUnit.start.called, "QUnit.start was called")

test "#setup fetches the reporter", ->
  runner = new Teaspoon.Qunit.Runner()
  runner.params = {grep: "foo"}
  reporter = ->
    reportRunnerStarting: ->
    reportRunnerResults: ->
    reportSuiteStarting: ->
    reportSuiteResults: ->
    reportSpecStarting: ->
    reportSpecResults: ->
  runner.getReporter = sinon.spy(-> reporter)

  runner.setup()

  ok(runner.getReporter.called, "#getReporter was called")
