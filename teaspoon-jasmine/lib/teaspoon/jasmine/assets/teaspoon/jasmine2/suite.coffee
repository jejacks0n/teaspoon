class Teaspoon.Jasmine2.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullName
    @description = @suite.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @suite.parent
    @viewId = @suite.id
