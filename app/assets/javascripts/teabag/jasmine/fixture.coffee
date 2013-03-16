class Teabag.fixture extends Teabag.fixture

  window.fixture = @

  @load: ->
    args = arguments
    throw "Teabag can't load fixtures outside of describe." unless env.currentSuite || env.currentSpec
    if env.currentSuite
      env.beforeEach => fixture.__super__.constructor.load.apply(@, args)
      env.afterEach => @cleanup()
      super
    else
      env.currentSpec.after => @cleanup()
      super


  @set: ->
    args = arguments
    throw "Teabag can't load fixtures outside of describe." unless env.currentSuite || env.currentSpec
    if env.currentSuite
      env.beforeEach => fixture.__super__.constructor.set.apply(@, args)
      env.afterEach => @cleanup()
      super
    else
      env.currentSpec.after => @cleanup()
      super


# set the environment
env = jasmine.getEnv()
