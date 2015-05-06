class Teaspoon.Jasmine1.Suite extends Teaspoon.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.getFullName()
    @description = @suite.description
    @link = @filterUrl(@fullDescription)
    @parent = @suite.parentSuite
    @viewId = @suite.viewId
