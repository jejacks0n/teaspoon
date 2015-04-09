class Teaspoon.Qunit.Runner extends Teaspoon.Runner

  constructor: ->
    super
    QUnit.start()


  setup: ->
    reporter = new (@getReporter())()
    new Teaspoon.Qunit.Responder(QUnit, reporter)


# Shim since core initializes the base class
# TODO: register the runner to use with core
class Teaspoon.Runner
  constructor: -> new Teaspoon.Qunit.Runner
