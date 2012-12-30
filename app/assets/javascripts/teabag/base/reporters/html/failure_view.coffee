class Teabag.Reporters.HTML.FailureView extends Teabag.Reporters.BaseView

  constructor: (@spec) ->
    super


  build: ->
    super("spec")
    html = """<h1 class="teabag-clearfix"><a href="#{@spec.link}">#{@spec.fullDescription}</a></h1>"""
    for error in @spec.errors()
      html += """<div><strong>#{@htmlSafe(error.message)}</strong><br/>#{@htmlSafe(error.stack || "Stack trace unavailable")}</div>"""
    @el.innerHTML = html
