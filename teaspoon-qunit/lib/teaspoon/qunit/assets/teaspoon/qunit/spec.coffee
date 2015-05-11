class Teaspoon.Qunit.Spec extends Teaspoon.Spec

  constructor: (@spec) ->
    @fullDescription = "#{@spec.module} #{@spec.name}"
    @description = "#{@spec.name} (#{@spec.failed}, #{@spec.passed}, #{@spec.total})"
    @link = @filterUrl("#{@spec.module}: #{@spec.name}")
    @parent = if @spec.module then new Teaspoon.Qunit.Suite({description: @spec.module}) else null
    @suiteName = @spec.module
    @viewId = @spec.viewId
    @pending = false


  errors: ->
    return [] unless @spec.failed
    for item in @spec.assertions
      continue if item.result
      @provideFallbackMessage(item)
      {message: item.message, stack: item.source}


  getParents: ->
    return [] unless @parent
    [@parent]


  result: ->
    status = "failed"
    status = "passed" if @spec.failed == 0
    status: status
    skipped: false


  provideFallbackMessage: (item) ->
    return if item.message

    if item.actual && item.expected
      item.message ||= "Expected #{JSON.stringify(item.actual)} to equal #{JSON.stringify(item.expected)}"
    else
      item.message = 'failed'


# Shim since core still initializes this class, but the argument
# is the real spec object passed in from the responder.
class Teaspoon.Spec
  constructor: (spec) -> return spec
