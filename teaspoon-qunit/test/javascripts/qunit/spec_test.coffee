module "Teaspoon.Qunit.Spec",
  setup: ->
    @mockAssertions = [
      {message: "_qunit_message1_", source: "_source1_"}
      {message: "_qunit_message2_", source: "_source2_"}
      {source: "_source3_", expected: 1, actual: 2}
      {source: "_source4_"}
    ]
    @mockSpec =
      module: "_full qunit name_"
      name: "_description_"
      failed: 1
      passed: 2
      total: 3
      viewId: 420
      assertions: @mockAssertions

test "constructor", 7, ->
  originalParams = Teaspoon.params
  Teaspoon.params.file = "spec.js"

  spec = new Teaspoon.Qunit.Spec(@mockSpec)
  ok(spec.fullDescription == "_full qunit name_ _description_", "sets fullDescription")
  ok(spec.description == "_description_ (1, 2, 3)", "sets description")
  ok(spec.link == "?grep=_full%20qunit%20name_%3A%20_description_&file=spec.js", "sets link")
  ok(spec.parent.description == "_full qunit name_", "builds a parent suite")
  ok(spec.suiteName == "_full qunit name_", "sets suiteName")
  ok(spec.viewId == 420, "sets viewId")
  ok(spec.pending == false, "sets pending to false") # no pending support

  Teaspoon.params = originalParams

test "#errors", 5, ->
  errors = new Teaspoon.Qunit.Spec(@mockSpec).errors()
  ok(errors.length == 4, "returns the correct length array")
  equal(errors[0].message, "_qunit_message1_", "the first item in the returned array is correct")
  equal(errors[0].stack, "_source1_", "the first item in the returned array is correct")
  equal(errors[2].message, "Expected 2 to equal 1", "a nice fallback message is provided if QUnit does not provide one")
  equal(errors[3].message, "failed", "some fallback message is provided if QUnit does not provide any information")

test "#getParents", 3, ->
  spec = new Teaspoon.Qunit.Spec(@mockSpec)
  ok(spec.getParents().length == 1, "returns the right number of parents")
  ok(spec.getParents()[0].description == "_full qunit name_", "the parent has a description")

  delete(@mockSpec.module)
  spec = new Teaspoon.Qunit.Spec(@mockSpec)
  ok(spec.getParents().length == 0, "returns an empty array")

test "#result", 3, ->
  @mockSpec.failed = 0
  result = new Teaspoon.Qunit.Spec(@mockSpec).result()
  ok(result.status == "passed", "sets the status to passed")
  ok(result.skipped == false, "sets skipped to false") # ever skipped?

  @mockSpec.failed = 1
  result = new Teaspoon.Qunit.Spec(@mockSpec).result()
  ok(result.status == "failed", "sets the status to failed")
