module "QUnit Teabag.Runner",
  setup: ->
    QUnit.start = sinon.spy()
    Teabag.Runner.prototype.reportRunnerStarting = sinon.spy()

test "constructor", 1, ->
  new Teabag.Runner()
  ok(QUnit.start.called, "QUnit.start was called")

test "#setup", ->
  runner = new Teabag.Runner()
  runner.params = {grep: "foo"}
  reporter = ->
  runner.getReporter = sinon.spy(-> reporter)

  runner.setup()

  ok(runner.getReporter.called, "#getReporter was called")
