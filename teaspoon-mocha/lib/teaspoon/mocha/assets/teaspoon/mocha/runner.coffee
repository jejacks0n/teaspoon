class Teaspoon.Mocha.Runner extends Teaspoon.Runner

  constructor: ->
    super
    window.env.run()
    window.env.started = true
    afterEach -> Teaspoon.fixture.cleanup()


  setup: ->
    # add the reporter and set the filter
    reporter = new (@getReporter())()
    Teaspoon.Mocha.Responder::reporter = reporter
    window.env.setup(reporter: Teaspoon.Mocha.Responder)


# Shim since core initializes the base class
# TODO: register the runner to use with core
class Teaspoon.Runner
  constructor: -> new Teaspoon.Mocha.Runner
