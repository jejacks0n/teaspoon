module "QUnit Teaspoon.Spec",
  setup: ->
    @mockAssertions = [
      {message: "_qunit_message1_", source: "_source1_"}
      {message: "_qunit_message2_", source: "_source2_"}
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
  spec = new Teaspoon.Spec(@mockSpec)
  ok(spec.fullDescription == "_full qunit name_ _description_", "sets fullDescription")
  ok(spec.description == "_description_ (1, 2, 3)", "sets description")
  ok(spec.link == "?grep=_full%20qunit%20name_%3A%20_description_", "sets link")
  ok(spec.parent.description == "_full qunit name_", "builds a parent suite")
  ok(spec.suiteName == "_full qunit name_", "sets suiteName")
  ok(spec.viewId == 420, "sets viewId")
  ok(spec.pending == false, "sets pending to false") # no pending support

test "#errors", 3, ->
  errors = new Teaspoon.Spec(@mockSpec).errors()
  ok(errors.length == 2, "returns the correct length array")
  equal(errors[0].message, "_qunit_message1_", "the first item in the returned array is correct")
  equal(errors[0].stack, "_source1_", "the first item in the returned array is correct")

test "#getParents", 3, ->
  spec = new Teaspoon.Spec(@mockSpec)
  ok(spec.getParents().length == 1, "returns the right number of parents")
  ok(spec.getParents()[0].description == "_full qunit name_", "the parent has a description")

  delete(@mockSpec.module)
  spec = new Teaspoon.Spec(@mockSpec)
  ok(spec.getParents().length == 0, "returns an empty array")

test "#result", 3, ->
  @mockSpec.failed = 0
  result = new Teaspoon.Spec(@mockSpec).result()
  ok(result.status == "passed", "sets the status to passed")
  ok(result.skipped == false, "sets skipped to false") # ever skipped?

  @mockSpec.failed = 1
  result = new Teaspoon.Spec(@mockSpec).result()
  ok(result.status == "failed", "sets the status to failed")



module "QUnit Teaspoon.Suite",
  setup: ->
    @mockSuite = description: "_full qunit description_"

test "constructor", 4, ->
  suite = new Teaspoon.Suite(@mockSuite)
  ok(suite.fullDescription == "_full qunit description_", "sets fullDescription")
  ok(suite.description == "_full qunit description_", "sets description")
  ok(suite.link == "?grep=_full%20qunit%20description_", "sets link")
  ok(suite.parent == null, "sets parent to null") # no structure to consider
