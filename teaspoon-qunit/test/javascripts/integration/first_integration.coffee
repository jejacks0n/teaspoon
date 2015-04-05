#= require integration/test_helper

module "Integration tests"

test "allows failing specs", ->
  ok(true == false, "fails correctly")

test "allows erroring specs", ->
  # todo: calling foo() isn't really possible as it stops the suite
  ok(true == false, "errors correctly")

test "allows passing specs", ->
  console.log('it can log to the console')
  ok(true == true)
