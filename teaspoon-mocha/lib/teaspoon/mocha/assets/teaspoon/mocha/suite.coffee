class Teaspoon.Mocha.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullTitle()
    @description = @suite.title
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = if @suite.parent?.root then null else @suite.parent
    @viewId = @suite.viewId


# Shim since HTML.SuiteView still initializes the base class.
# TODO: inject instance into SuiteView
class Teaspoon.Suite
  constructor: (suite) ->
    return new Teaspoon.Mocha.Suite(suite)
