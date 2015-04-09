class Teaspoon.Reporters.HTML extends Teaspoon.Reporters.HTML

  reportRunnerResults: (runner) ->
    version = Teaspoon.Qunit.version()
    if version.major = 1 && version.minor < 16
      # QUnit <= 1.15 doesn't provide the total until all tests are finished
      # The .begin hook is broken
      @total.exist = @total.run = runner.total
    super


  readConfig: ->
    super
    QUnit.config.notrycatch = @config["use-catch"]


  envInfo: ->
    "qunit #{Teaspoon.Qunit.rawVersion() || "[unknown version]"}"


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
