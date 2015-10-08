class Teaspoon.Jasmine2.Spec extends Teaspoon.Spec

  constructor: (@spec) ->
    @fullDescription = @spec.fullName
    @description = @spec.description
    @link = @filterUrl(@fullDescription)
    @parent = @spec.parent
    # spec may not have a parent if it's being focused
    @suiteName = @parent.fullName if @parent
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
      parent = new Teaspoon.Jasmine2.Suite(parent)
      @parents.unshift(parent)
      parent = parent.parent
    @parents


  result: ->
    status: @status()
    skipped: @spec.status == "disabled" || @pending


  status: ->
    if @spec.status == "disabled" then "passed" else @spec.status
