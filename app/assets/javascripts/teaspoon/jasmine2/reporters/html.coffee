class Teaspoon.Reporters.HTML extends Teaspoon.Reporters.HTML

  readConfig: ->
    super
    jasmine.CATCH_EXCEPTIONS = @config["use-catch"]


  envInfo: ->
    "jasmine #{jasmine.version}"


  jasmineStarted: (result) ->
    @reportRunnerStarting(total: result.totalSpecsDefined)


  jasmineDone: ->
    @reportRunnerResults()


  suiteStarted: (result) ->
    if @currentSuite # suite already running, we're nested
      result.parent = @currentSuite
    @currentSuite = result


  suiteDone: (result) ->
    @currentSuite = @currentSuite.parent


  specStarted: (result) ->
    # Jasmine 2 reports the spec starting even though it may
    # be filtered out, but there's no way to tell.
    # TODO: Is there a way to clean this up?
    if jasmine.getEnv().specFilter(getFullName: -> result.fullName)
      result.parent = @currentSuite
      @reportSpecStarting(result)


  specDone: (result) ->
    result.parent = @currentSuite
    @reportSpecResults(result)
