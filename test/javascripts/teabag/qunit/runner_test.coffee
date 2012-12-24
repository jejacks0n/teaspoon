module "QUnit Teabag.Runner",
  setup: ->
    sinon.spy(QUnit, "start")
  teardown: ->
    QUnit.start.restore()


test "constructor", 1, ->
  new Teabag.Runner()
  ok(QUnit.start.called, "QUnit.start was called")


test "#setup", ->
  runner = new Teabag.Runner()
  runner.params = {grep: "foo"}
  reporter = ->
  reporter.prototype.setFilter = sinon.spy()
  runner.getReporter = sinon.spy(-> reporter)

  runner.setup()

  ok(runner.getReporter.called, "#getReporter was called")
  ok(reporter.prototype.setFilter.args[0][0] == "foo", "#setFilter was called with 'foo'")
