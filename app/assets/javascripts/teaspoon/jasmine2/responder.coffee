class Teaspoon.Jasmine2.Responder extends Teaspoon.Runner

  constructor: (@reporter) ->

  
  jasmineStarted: (result) ->
    @reporter.reportRunnerStarting(total: result.totalSpecsDefined)

  
  jasmineDone: ->
    @reporter.reportRunnerResults()


  suiteStarted: (result) ->
    if @currentSuite # suite already running, we're nested
      result.parent = @currentSuite
    @currentSuite = result

    @reporter.reportSuiteStarting?(
      id: result.id
      description: result.description
      fullName: result.fullName
    )


  suiteDone: (result) ->
    @currentSuite = @currentSuite.parent

    @reporter.reportSuiteResults?(
      id: result.id
      description: result.description
      fullName: result.fullName
    )


  specStarted: (result) ->
    # Jasmine 2 reports the spec starting even though it may
    # be filtered out, but there's no way to tell.
    # TODO: Is there a way to clean this up?
    if jasmine.getEnv().specFilter(getFullName: -> result.fullName)
      result.parent = @currentSuite
      @reporter.reportSpecStarting?(result)


  specDone: (result) ->
    result.parent = @currentSuite
    @reporter.reportSpecResults(result)
