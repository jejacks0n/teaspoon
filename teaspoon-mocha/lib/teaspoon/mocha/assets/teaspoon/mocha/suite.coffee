class Teaspoon.Mocha.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullTitle()
    @description = @suite.title
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = if @suite.parent?.root then null else @suite.parent
    @viewId = @suite.viewId
