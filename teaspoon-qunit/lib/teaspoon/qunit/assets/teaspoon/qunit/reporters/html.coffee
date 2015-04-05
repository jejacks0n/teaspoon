class Teaspoon.Reporters.HTML extends Teaspoon.Reporters.HTML

  constructor: (env) ->
    super
    env.log(@reportSpecResults)
    env.testDone(@reportSpecResults)
    env.done(@reportRunnerResults)
    @currentAssertions = []
    @reportRunnerStarting()


  reportRunnerStarting: ->
    @total.exist = null
    @setText("stats-duration", "...")


  reportSpecResults: (spec) =>
    unless typeof(spec.total) == "number"
      @currentAssertions.push(spec)
      return
    spec.assertions = @currentAssertions
    @currentAssertions = []
    @reportSpecStarting(spec)
    super(spec)


  reportRunnerResults: (result) =>
    @total.exist = @total.run = result.total
    super


  readConfig: ->
    super
    QUnit.config.notrycatch = @config["use-catch"]


  envInfo: ->
    "qunit #{_qunit_version || "[unknown version]"}"



class Teaspoon.Reporters.HTML.SpecView extends Teaspoon.Reporters.HTML.SpecView

  buildErrors: ->
    div = @createEl("div")
    html = ""
    for error in @spec.errors()
      html += """<strong>#{error.message}</strong><br/>#{@htmlSafe(error.stack || "Stack trace unavailable")}<br/>"""
    div.innerHTML = html
    @append(div)


  buildParent: ->
    parent = @spec.parent
    return @reporter unless parent
    if @views.suites[parent.description]
      @views.suites[parent.description]
    else
      view = new Teaspoon.Reporters.HTML.SuiteView(parent, @reporter)
      @views.suites[parent.description] = view



class Teaspoon.Reporters.HTML.FailureView extends Teaspoon.Reporters.HTML.FailureView

  build: ->
    super("spec")
    html = """<h1 class="teaspoon-clearfix"><a href="#{@spec.link}">#{@htmlSafe(@spec.fullDescription)}</a></h1>"""
    for error in @spec.errors()
      html += """<div><strong>#{error.message}</strong><br/>#{@htmlSafe(error.stack || "Stack trace unavailable")}</div>"""
    @el.innerHTML = html



class Teaspoon.Reporters.HTML.SuiteView extends Teaspoon.Reporters.HTML.SuiteView

  constructor: (@suite, @reporter) ->
    @views = @reporter.views
    @views.suites[@suite.description] = @
    @build()
