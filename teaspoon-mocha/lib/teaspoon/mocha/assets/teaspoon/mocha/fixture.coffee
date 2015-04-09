class Teaspoon.Mocha.Fixture extends Teaspoon.fixture

  @load: ->
    args = arguments
    if window.env.started then super
    else beforeEach => fixture.__super__.constructor.load.apply(@, args)


  @set: ->
    args = arguments
    if window.env.started then super
    else beforeEach => fixture.__super__.constructor.set.apply(@, args)


# TODO: Register fixture framework with core
window.fixture = Teaspoon.Mocha.Fixture
