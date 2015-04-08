class Teaspoon.Jasmine1.Spec

  constructor: (@spec) ->
    @fullDescription = @spec.getFullName()
    @description = @spec.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
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
      parent = new Teaspoon.Suite(parent)
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


# Shim since core still initializes this class, but the argument
# is the real spec object passed in from the responder.
# TODO: remove and register spec class with core
class Teaspoon.Spec
  constructor: (spec) ->
    return if spec instanceof Teaspoon.Jasmine1.Spec
      spec
    else
      new Teaspoon.Jasmine1.Spec(spec)
