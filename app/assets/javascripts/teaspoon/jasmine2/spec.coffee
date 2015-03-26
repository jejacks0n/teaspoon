class Teaspoon.Jasmine2.Spec

  constructor: (@spec) ->
    @fullDescription = @spec.fullName
    @description = @spec.description
    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
    @parent = @spec.parent
    @suiteName = @parent.fullName
    @viewId = @spec.id
    @pending = @spec.status == "pending"


  errors: ->
    return [] unless @spec.failedExpectations.length
    for item in @spec.failedExpectations
      {message: item.message, stack: item.stack}


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
    status: @status()
    skipped: @spec.status == "disabled"


  status: ->
    if @spec.status == "disabled" then "passed" else @spec.status


# Shim since core still initializes this class, but the argument
# is the real spec object passed in from the responder.
class Teaspoon.Spec
  constructor: (spec) -> return spec