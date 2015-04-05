class Teaspoon.Jasmine.Responder

  constructor: (@reporter) ->

  
  reportRunnerStarting: (runner) ->
    @reporter.reportRunnerStarting(total: runner.specs().length)

  
  reportRunnerResults: ->
    @reporter.reportRunnerResults()


  reportSuiteResults: (suite) ->
    @reporter.reportSuiteResults(
      id: suite.id
      description: suite.description
      fullName: suite.getFullName()
    )


  reportSpecStarting: (spec) ->
    @reporter.reportSpecStarting(spec)


  reportSpecResults: (spec) ->
    @reporter.reportSpecResults(spec)
