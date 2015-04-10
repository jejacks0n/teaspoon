#= require teaspoon/reporters/html/suite_view

class Teaspoon.Qunit.Reporters.HTML.SuiteView extends Teaspoon.Reporters.HTML.SuiteView

  constructor: (@suite, @reporter) ->
    @views = @reporter.views
    @views.suites[@suite.description] = @
    @build()
