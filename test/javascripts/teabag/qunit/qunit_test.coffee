console.log("testing console output")

module "Teabag running QUnit"

test "is awesome", ->
  ok(passing == true, "Passing is true")
  ok(passing == true, "Passing is true")

#
#module "running tests"
#
#test "actually tests", 2, ->
#  ok(true, "passing")
#  ok(true, "passing")
#
#test "can handle more than one test", ->
#  expect(1)
#  stop()
#  setTimeout ->
#    ok(passing == true, "Passing is true")
#    start()
#  , 1000
#
#
#module "failing tests"
#
#test "can fail", ->
#  ok(failing == false, "Failing is false")
