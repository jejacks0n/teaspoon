#= require teaspoon/fixture

class Teaspoon.Jasmine2.Fixture extends Teaspoon.Fixture

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
