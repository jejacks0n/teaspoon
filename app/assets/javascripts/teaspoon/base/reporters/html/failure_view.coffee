class Teaspoon.Reporters.HTML.FailureView extends Teaspoon.Reporters.BaseView

  constructor: (@spec) ->
    super


  build: ->
    super("spec")
    html = """<h1 class="teaspoon-clearfix"><a href="#{@spec.link}">#{@htmlSafe(@spec.fullDescription)}</a></h1>"""
    for error in @spec.errors()
      html += """<div>"""
      html += """<strong>#{@htmlSafe(error.message)}</strong><br/>"""
      html += """<strong>Expected:</strong> <code>#{@inspect(error.expected)}</code><br/>""" if error.hasOwnProperty('expected')
      html += """<strong>Actual:</strong> <code>#{@inspect(error.actual)}</code><br/>""" if error.hasOwnProperty('actual')
      html += """#{@htmlSafe(error.stack || "Stack trace unavailable")}"""
      html += """</div>"""
    @el.innerHTML = html
