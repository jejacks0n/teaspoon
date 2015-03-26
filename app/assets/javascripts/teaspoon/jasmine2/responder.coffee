class Teaspoon.Jasmine2.Responder

  constructor: (@reporter) ->

  
  jasmineStarted: (runner) ->
    @reporter.reportRunnerStarting(total: runner.totalSpecsDefined)

  
  jasmineDone: ->
    @reporter.reportRunnerResults()


  suiteStarted: (suite) ->
    if @currentSuite # suite already running, we're nested
      suite.parent = @currentSuite
    @currentSuite = suite

    @reporter.reportSuiteStarting(new Teaspoon.Jasmine2.Suite(suite))


  suiteDone: (suite) ->
    @currentSuite = @currentSuite.parent

    @reporter.reportSuiteResults(new Teaspoon.Jasmine2.Suite(suite))


  specStarted: (spec) ->
    # Jasmine 2 reports the spec starting even though it may
    # be filtered out, but there's no way to tell.
    # TODO: Is there a way to clean this up?
    if jasmine.getEnv().specFilter(getFullName: -> spec.fullName)
      spec.parent = @currentSuite
      @reporter.reportSpecStarting(new Teaspoon.Jasmine2.Spec(spec))


  specDone: (spec) ->
    spec.parent = @currentSuite
    @reporter.reportSpecResults(new Teaspoon.Jasmine2.Spec(spec))
