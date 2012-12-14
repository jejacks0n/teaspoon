class Teabag.Reporters.HTML.SpecView extends Teabag.Reporters.BaseView

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
    @el.innerHTML = """<a href="#{@spec.link}">#{@spec.description}</a>"""
    @parentView = @buildParent()
    @parentView.append(@el)


  buildParent: ->
    parent = @spec.parent
    if parent.viewId
      @views.suites[parent.viewId]
    else
      view = new Teabag.Reporters.HTML.SuiteView(parent, @reporter)
      @views.suites[view.suite.viewId] = view


  buildErrors: ->
    div = @createEl("div")
    html = ""
    for error in @spec.errors()
      html += """#{@htmlSafe(error.stack || error.message || "Stack trace unavailable")}"""
    div.innerHTML = html
    @append(div)


  updateState: (state, elapsed) ->
    result = @spec.result()
    classes = ["state-#{state}"]
    classes.push("slow") if elapsed > Teabag.slow
    @el.innerHTML += "<span>#{elapsed}ms</span>" unless state == "failed"
    @el.className = classes.join(" ")
    @buildErrors() unless result.status == "passed"
    @parentView.updateState?(state)
