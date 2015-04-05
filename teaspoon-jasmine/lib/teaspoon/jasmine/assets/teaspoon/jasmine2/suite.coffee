class Teaspoon.Jasmine2.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullName
    @description = @suite.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @suite.parent
    @viewId = @suite.id


# Shim since HTML.SuiteView still initializes the base class.
# TODO: inject instance into SuiteView
class Teaspoon.Suite
  constructor: (suite) ->
    return new Teaspoon.Jasmine2.Suite(suite)
