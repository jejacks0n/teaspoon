class Teaspoon.Reporters.HTML.FailureView extends Teaspoon.Reporters.BaseView

  constructor: (@spec) ->
    super


  build: ->
    super("spec")
    html = """<h1 class="teaspoon-clearfix"><a href="#{@spec.link}">#{@htmlSafe(@spec.fullDescription)}</a></h1>"""
    for error in @spec.errors()
      html += """<div><strong>#{@htmlSafe(error.message)}</strong><br/>#{@htmlSafe(error.stack || "Stack trace unavailable")}</div>"""
    @el.innerHTML = html
