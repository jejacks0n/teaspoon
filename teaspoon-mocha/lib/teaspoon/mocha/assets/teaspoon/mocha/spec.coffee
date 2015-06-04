class Teaspoon.Mocha.Spec extends Teaspoon.Spec

  constructor: (@spec) ->
    @fullDescription = @spec.fullTitle()
    @description = @spec.title
    @link = @filterUrl(@fullDescription)
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
      parent = new Teaspoon.Mocha.Suite(parent)
      @parents.unshift(parent)
      parent = parent.parent
    @parents


  result: ->
    status = "failed"
    status = "passed" if @spec.state == "passed" || @spec.state == "skipped"
    status = "pending" if @spec.pending

    status: status
    skipped: @spec.state == "skipped" || @pending
