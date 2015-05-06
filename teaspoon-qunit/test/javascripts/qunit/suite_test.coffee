module "Teaspoon.Qunit.Suite",
  setup: ->
    @mockSuite = description: "_full qunit description_"

test "constructor", 4, ->
  originalParams = Teaspoon.params
  Teaspoon.params.file = "spec.js"

  suite = new Teaspoon.Qunit.Suite(@mockSuite)
  ok(suite.fullDescription == "_full qunit description_", "sets fullDescription")
  ok(suite.description == "_full qunit description_", "sets description")
  ok(suite.link == "?grep=_full%20qunit%20description_&file=spec.js", "sets link")
  ok(suite.parent == null, "sets parent to null") # no structure to consider

  Teaspoon.params = originalParams
