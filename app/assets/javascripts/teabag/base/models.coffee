class Teabag.Spec

  constructor: (@spec) ->
    @fullDescription = @spec.getFullName?() || @spec.fullTitle()
    @description ||= @spec.description || @spec.title
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @spec.suite || @spec.parent
    @suiteName = @parent.getFullName?() || @parent.fullTitle()
    @viewId = @spec.viewId
    @pending = @spec.pending


  errors: ->
    return [@spec.err] if @spec.err
    return [] unless @spec.results
    for item in @spec.results().getItems()
      continue if item.passed()
      {message: item.message, stack: item.trace.stack}


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
    if @spec.results
      results = @spec.results()
      status = "passed" if results.passed()
      skipped = results.skipped
    else
      status = "passed" if @spec.state == "passed" || @spec.state == "skipped"
      skipped = @spec.state == "skipped"
    status = "pending" if @spec.pending
    status: status
    skipped: skipped



class Teabag.Suite

  constructor: (@suite) ->
    @fullDescription = @suite.getFullName?() || @suite.fullTitle()
    @description = @suite.description || @suite.title
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @getParent()
    @viewId = @suite.viewId


  getParent: ->
    if @suite.parent
      if @suite.parent.root then null else @suite.parent
    else
      @suite.parentSuite
