class Teaspoon.Jasmine1.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.getFullName()
    @description = @suite.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @suite.parentSuite
    @viewId = @suite.viewId


# Shim since HTML.SuiteView still initializes the base class.
# TODO: inject instance into SuiteView
class Teaspoon.Suite
  constructor: (suite) ->
    return new Teaspoon.Jasmine1.Suite(suite)
