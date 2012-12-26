#= require mocha-1.7.4
#= require teabag/base/teabag
#= require teabag/mocha/reporters/console
#= require teabag/mocha/reporters/html

class Teabag.Runner extends Teabag.Runner

  env = mocha.setup("bdd")

  constructor: ->
    super
    env.run()


  setup: ->
    # add the reporter and set the filter
    reporter = @getReporter()
    reporter.filter = @params["grep"]
    env.setup(reporter: reporter)



class Teabag.Spec

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
      parent = new Teabag.Suite(parent)
      @parents.unshift(parent)
      parent = parent.parent
    @parents


  result: ->
    status = "failed"
    status = "passed" if @spec.state == "passed" || @spec.state == "skipped"
    status = "pending" if @spec.pending
    status: status
    skipped: @spec.state == "skipped"



class Teabag.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.fullTitle()
    @description = @suite.title
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = if @suite.parent.root then null else @suite.parent
    @viewId = @suite.viewId
