class Teaspoon.Jasmine1.Spec extends Teaspoon.Spec

  constructor: (@spec) ->
    @fullDescription = @spec.getFullName()
    @description = @spec.description
    @link = @filterUrl(@fullDescription)
    @parent = @spec.suite
    @suiteName = @parent.getFullName()
    @viewId = @spec.viewId
    @pending = @spec.pending


  errors: ->
    return [] unless @spec.results
    for item in @spec.results().getItems()
      continue if item.passed()
      {message: item.message, stack: item.trace.stack}


  getParents: ->
    return @parents if @parents
    @parents ||= []
    parent = @parent
    while parent
      parent = new Teaspoon.Jasmine1.Suite(parent)
      @parents.unshift(parent)
      parent = parent.parent
    @parents


  result: ->
    results = @spec.results()
    status = "failed"
    status = "passed" if results.passed()
    status = "pending" if @spec.pending
    status: status
    skipped: results.skipped
