class Teaspoon.Qunit.Suite extends Teaspoon.Suite

  constructor: (@suite) ->
    # In QUnit 1.14, moduleStart uses @suite.name,
    # moduleDone uses @suite.description
    @fullDescription = @suite.description || @suite.name
    @description = @suite.description || @suite.name
    @link = @filterUrl(@fullDescription)
    @parent = null
