class Teaspoon.Reporters.HTML.SuiteView extends Teaspoon.Reporters.BaseView

  viewId = 0

  constructor: (@suite, @reporter) ->
    @views = @reporter.views
    @suite.viewId = viewId += 1
    @views.suites[@suite.viewId] = @
    @suite = new Teaspoon.Suite(suite)
    super


  build: ->
    super("suite")
    @el.innerHTML = """<h1><a href="#{@suite.link}">#{@htmlSafe(@suite.description)}</a></h1>"""
    @parentView = @buildParent()
    @parentView.append(@el)


  buildParent: ->
    parent = @suite.parent
    return @reporter unless parent
    if parent.viewId
      @views.suites[parent.viewId]
    else
      view = new Teaspoon.Reporters.HTML.SuiteView(parent, @reporter)
      @views.suites[view.suite.viewId] = view


  append: (el) ->
    super(@ol = @createEl("ol")) unless @ol
    @ol.appendChild(el)


  updateState: (state) ->
    return if @state == "failed"
    @el.className = "#{@el.className.replace(/\s?state-\w+/, "")} state-#{state}"
    @parentView.updateState?(state)
    @state = state
