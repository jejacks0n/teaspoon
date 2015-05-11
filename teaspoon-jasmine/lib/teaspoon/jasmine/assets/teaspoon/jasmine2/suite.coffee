class Teaspoon.Jasmine2.Suite extends Teaspoon.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullName
    @description = @suite.description
    @link = @filterUrl(@fullDescription)
    @parent = @suite.parent
    @viewId = @suite.id
