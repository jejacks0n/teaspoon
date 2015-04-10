#= require teaspoon/reporters/html/failure_view

class Teaspoon.Qunit.Reporters.HTML.FailureView extends Teaspoon.Reporters.HTML.FailureView

  build: ->
    super("spec")
    html = """<h1 class="teaspoon-clearfix"><a href="#{@spec.link}">#{@htmlSafe(@spec.fullDescription)}</a></h1>"""
    for error in @spec.errors()
      html += """<div><strong>#{error.message}</strong><br/>#{@htmlSafe(error.stack || "Stack trace unavailable")}</div>"""
    @el.innerHTML = html
