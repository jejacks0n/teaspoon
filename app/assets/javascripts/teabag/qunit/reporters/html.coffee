class Teabag.Reporters.HTML extends Teabag.Reporters.HTML

  constructor: (env) ->
    super
    env.log(@reportSpecResults)
    env.testDone(@reportSpecResults)
    env.done(@reportRunnerResults)
    @reportRunnerStarting()


  reportRunnerStarting: ->
    @currentAssertions = []
    @total.exist = null
    @setText("stats-duration", "...")


  reportSpecResults: (result) =>
    unless typeof(result.total) == "number"
      @currentAssertions.push(result)
      return
    result.assertions = @currentAssertions
    @currentAssertions = []
    @reportSpecStarting(result)
    super(result)


  reportRunnerResults: (result) =>
    @total.exist = @total.run = result.total
    super


  readConfig: ->
    super
    QUnit.config.notrycatch = @config["use-catch"]


  envInfo: ->
    "qunit 1.10.0"



class Teabag.Reporters.HTML.SpecView extends Teabag.Reporters.HTML.SpecView

  buildErrors: ->
    div = @createEl("div")
    html = ""
    for error in @spec.errors()
      html += """<strong>#{error.message}</strong><br/>#{@htmlSafe(error.stack || "Stack trace unavailable")}<br/>"""
    div.innerHTML = html
    @append(div)


  buildParent: ->
    parent = @spec.parent
    if @views.suites[parent.description]
      @views.suites[parent.description]
    else
      view = new Teabag.Reporters.HTML.SuiteView(parent, @reporter)
      @views.suites[parent.description] = view



class Teabag.Reporters.HTML.FailureView extends Teabag.Reporters.HTML.FailureView

  build: ->
    super("spec")
    html = """<h1 class="teabag-clearfix"><a href="#{@spec.link}">#{@spec.fullDescription}</a></h1>"""
    for error in @spec.errors()
      html += """<div><strong>#{error.message}</strong><br/>#{@htmlSafe(error.stack || "Stack trace unavailable")}</div>"""
    @el.innerHTML = html



class Teabag.Reporters.HTML.SuiteView extends Teabag.Reporters.HTML.SuiteView

  constructor: (@suite, @reporter) ->
    @views = @reporter.views
    @views.suites[@suite.description] = @
    @build()
