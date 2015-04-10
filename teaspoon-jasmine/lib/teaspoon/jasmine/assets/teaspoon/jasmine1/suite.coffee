class Teaspoon.Jasmine1.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.getFullName()
    @description = @suite.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @suite.parentSuite
    @viewId = @suite.viewId
