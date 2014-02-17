#= require teaspoon/base/teaspoon
#= require teaspoon/mocha/reporters/console
#= require teaspoon/mocha/reporters/html

unless mocha?
  throw new Teaspoon.Error('Mocha not found -- use `suite.use_framework :mocha` and adjust or remove the `suite.javascripts` directive.')

class Teaspoon.Runner extends Teaspoon.Runner

  constructor: ->
    super
    env.run()
    env.started = true
    afterEach -> Teaspoon.fixture.cleanup()


  setup: ->
    # add the reporter and set the filter
    reporter = @getReporter()
    env.setup(reporter: reporter)



class Teaspoon.Spec

  constructor: (@spec) ->
    @fullDescription = @spec.fullTitle()
    @description = @spec.title
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @spec.parent
    @suiteName = @parent.fullTitle()
    @viewId = @spec.viewId
    @pending = @spec.pending


  errors: ->
    return [] unless @spec.err
    [@spec.err]


  getParents: ->
    return @parents if @parents
    @parents ||= []
    parent = @parent
    while parent
      parent = new Teaspoon.Suite(parent)
      @parents.unshift(parent)
      parent = parent.parent
    @parents


  result: ->
    status = "failed"
    status = "passed" if @spec.state == "passed" || @spec.state == "skipped"
    status = "pending" if @spec.pending
    status: status
    skipped: @spec.state == "skipped"



class Teaspoon.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullTitle()
    @description = @suite.title
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = if @suite.parent?.root then null else @suite.parent
    @viewId = @suite.viewId



class Teaspoon.fixture extends Teaspoon.fixture

  window.fixture = @

  @load: ->
    args = arguments
    if env.started then super
    else beforeEach => fixture.__super__.constructor.load.apply(@, args)


  @set: ->
    args = arguments
    if env.started then super
    else beforeEach => fixture.__super__.constructor.set.apply(@, args)



# set the environment
env = mocha.setup("bdd")
