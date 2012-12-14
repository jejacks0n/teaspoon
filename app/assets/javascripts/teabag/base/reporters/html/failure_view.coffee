class Teabag.Reporters.HTML.FailureView extends Teabag.Reporters.BaseView

  constructor: (@spec) ->
    super


  build: ->
    super("spec")
    html = """<h1 class="teabag-clearfix"><a href="#{@spec.link}">#{@spec.fullDescription}</a></h1>"""
    for error in @spec.errors()
      html += """<div>#{@htmlSafe(error.stack || error.message || "Stack trace unavailable")}</div>"""
    @el.innerHTML = html
