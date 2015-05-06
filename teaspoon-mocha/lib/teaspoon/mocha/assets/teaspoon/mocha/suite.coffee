class Teaspoon.Mocha.Suite extends Teaspoon.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullTitle()
    @description = @suite.title
    @link = @filterUrl(@fullDescription)
    @parent = if @suite.parent?.root then null else @suite.parent
    @viewId = @suite.viewId
