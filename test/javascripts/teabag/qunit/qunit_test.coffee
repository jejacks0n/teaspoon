console.log("testing console output")

test "doesn't need a module", ->
  ok(passing == true, "Passing is true")

module "Teabag running QUnit"

test "is awesome", ->
  ok(passing == true, "Passing is true")


module "Running tests"

test "actually tests", 2, ->
  ok(passing == true, "window.passing should be true")
  ok(failing == false, "window.failing should be false")

test "can handle more than one test", ->
  expect(1)
  stop()
  setTimeout ->
    ok(passing == true, "Passing is true")
    start()
  , 1000


module "Failing tests"

test "can fail", ->
  ok(failing == false, "Failing is false")
  ok(failing == false, "Failing is false")
