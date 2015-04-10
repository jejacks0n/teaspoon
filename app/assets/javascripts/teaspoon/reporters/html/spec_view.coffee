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


  updateState: (state, elapsed) ->
    result = @spec.result()
    classes = ["state-#{state}"]
    classes.push("slow") if elapsed > Teaspoon.slow
    @el.innerHTML += "<span>#{elapsed}ms</span>" if state == "passed"
    @el.className = classes.join(" ")
    @buildErrors() if result.status == "failed"
    @parentView.updateState?(state)
