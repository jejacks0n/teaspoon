#= require teaspoon/reporters/html/spec_view

class Teaspoon.Qunit.Reporters.HTML.SpecView extends Teaspoon.Reporters.HTML.SpecView

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
      view = new Teaspoon.Qunit.Reporters.HTML.SuiteView(parent, @reporter)
      @views.suites[parent.description] = view
