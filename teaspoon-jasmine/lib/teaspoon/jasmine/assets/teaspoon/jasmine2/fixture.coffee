class Teaspoon.Jasmine2.Fixture extends Teaspoon.fixture

  @load: ->
    args = arguments
    @env().beforeEach => fixture.__super__.constructor.load.apply(@, args)
    @env().afterEach => @cleanup()
    super


  @set: ->
    args = arguments
    @env().beforeEach => fixture.__super__.constructor.set.apply(@, args)
    @env().afterEach => @cleanup()
    super


  @env: -> window.jasmine.getEnv()


# TODO: Register fixture framework with core
window.fixture = Teaspoon.Jasmine2.Fixture
