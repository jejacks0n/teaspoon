class Teaspoon.Qunit.Suite

  constructor: (@suite) ->
    # In QUnit 1.14, moduleStart uses @suite.name,
    # moduleDone uses @suite.description
    @fullDescription = @suite.description || @suite.name
    @description = @suite.description || @suite.name
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = null


# Shim since HTML.SuiteView still initializes the base class.
# TODO: inject instance into SuiteView
class Teaspoon.Suite
  constructor: (suite) ->
    return new Teaspoon.Qunit.Suite(suite)
