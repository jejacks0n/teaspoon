#= require teaspoon/reporters/html/base_view

class Teaspoon.Reporters.HTML.SpecView extends Teaspoon.Reporters.BaseView

  viewId = 0

  constructor: (@spec, @reporter) ->
    @views = @reporter.views
    @spec.viewId = viewId += 1
    @views.specs[@spec.viewId] = @
    super


  build: ->
    classes = ["spec"]
    classes.push("state-pending") if @spec.pending
    super(classes.join(" "))
    @el.innerHTML = """<a href="#{@spec.link}">#{@htmlSafe(@spec.description)}</a>"""
    @parentView = @buildParent()
    @parentView.append(@el)


  buildParent: ->
    parent = @spec.parent
    return @reporter unless parent
    if parent.viewId
      @views.suites[parent.viewId]
    else
      view = new (Teaspoon.resolveClass("Reporters.HTML.SuiteView"))(parent, @reporter)
      @views.suites[view.suite.viewId] = view


  buildErrors: ->
    div = @createEl("div")
    html = ""
    for error in @spec.errors()
      html += """<strong>#{@htmlSafe(error.message)}</strong><br/>#{@htmlSafe(error.stack || "Stack trace unavailable")}"""
    div.innerHTML = html
    @append(div)


  updateState: (spec, elapsed) ->
    result = spec.result()
    @clearClasses()

    if result.status == "pending"
      @updatePending(spec, elapsed)
    else if result.status == "failed"
      @updateFailed(spec, elapsed)
    else if result.skipped
      @updateDisabled(spec, elapsed)
    else
      @updatePassed(spec, elapsed)


  updatePassed: (spec, elapsed) ->
    @addStatusClass("passed")
    @addClass("slow") if elapsed > Teaspoon.slow
    @el.innerHTML += "<span>#{elapsed}ms</span>"


  updateFailed: (spec, elapsed) ->
    @addStatusClass("failed")
    @buildErrors()
    @parentView.updateState?("failed")


  updatePending: (spec, elapsed) ->
    @addStatusClass("pending")


  updateDisabled: (spec, elapsed) -> # noop


  clearClasses: ->
    @el.className = ""


  addStatusClass: (status) ->
    @addClass("state-#{status}")


  addClass: (name) ->
    @el.className += " #{name}"
