class Teaspoon.Mocha.Spec

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


# Shim since core still initializes this class, but the argument
# is the real spec object passed in from the responder.
class Teaspoon.Spec
  constructor: (spec) -> return spec
