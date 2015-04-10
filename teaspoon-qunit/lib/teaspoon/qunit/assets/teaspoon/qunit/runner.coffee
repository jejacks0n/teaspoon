#= require teaspoon/runner

class Teaspoon.Qunit.Runner extends Teaspoon.Runner

  constructor: ->
    super
    QUnit.start()


  setup: ->
    reporter = new (@getReporter())()
    new Teaspoon.Qunit.Responder(QUnit, reporter)
