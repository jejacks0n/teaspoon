class Teaspoon.Reporters.HTML extends Teaspoon.Reporters.HTML

  readConfig: ->
    super
    jasmine.getEnv().catchExceptions(@config["use-catch"])
    @jasmineDone = @reportRunnerResults


  envInfo: ->
    "jasmine #{jasmine.version}"


  jasmineStarted: (runner) ->
    @reportRunnerStarting(total: runner.totalSpecsDefined)


  suiteStarted: (suite) ->
    suite.parent = @suite
    @suite = suite


  suiteDone: ->
    @suite = @suite.parent if @suite.parent


  specStarted: (spec) ->
    spec.suite = @suite
    @reportSpecStarting(spec)


  specDone: (spec) ->
    spec.suite = @suite
    @reportSpecResults(spec)
