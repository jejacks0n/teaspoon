#= require teaspoon/runner

class Teaspoon.Mocha.Runner extends Teaspoon.Runner

  constructor: ->
    super
    window.env.run()
    window.env.started = true
    afterEach -> Teaspoon.Mocha.Fixture.cleanup()


  setup: ->
    # add the reporter and set the filter
    reporter = new (@getReporter())()
    Teaspoon.Mocha.Responder::reporter = reporter
    window.env.setup(reporter: Teaspoon.Mocha.Responder)
