#= require teaspoon/fixture

class Teaspoon.Mocha.Fixture extends Teaspoon.Fixture

  @load: ->
    args = arguments
    if window.env.started then super
    else beforeEach => fixture.__super__.constructor.load.apply(@, args)


  @set: ->
    args = arguments
    if window.env.started then super
    else beforeEach => fixture.__super__.constructor.set.apply(@, args)
