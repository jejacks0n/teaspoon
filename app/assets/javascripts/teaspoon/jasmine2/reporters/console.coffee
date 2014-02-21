class Teaspoon.Reporters.Console extends Teaspoon.Reporters.Console

  constructor: ->
    super
    @jasmineDone = @reportRunnerResults


  jasmineStarted: (runner) ->
    try @reportRunnerStarting(total: runner.totalSpecsDefined)
    catch e
      console.log(e)


  suiteStarted: (suite) ->
    suite.parent = @suite
    @suite = suite


  suiteDone: ->
    @suite = @suite.parent if @suite.parent


  specStarted: (spec) ->
    spec.suite = @suite


  specDone: (spec) ->
    spec.suite = @suite
    @reportSpecResults(spec)
