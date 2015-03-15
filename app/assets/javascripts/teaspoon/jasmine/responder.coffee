class Teaspoon.Jasmine.Responder

  constructor: (@reporter) ->

  
  reportRunnerStarting: (runner) ->
    @reporter.reportRunnerStarting(total: runner.specs().length)

  
  reportRunnerResults: ->
    @reporter.reportRunnerResults()


  reportSuiteResults: (result) ->
    @reporter.reportSuiteResults?(
      id: result.id
      description: result.description
      fullName: result.getFullName()
    )


  reportSpecStarting: (result) ->
    @reporter.reportSpecStarting?(result)


  reportSpecResults: (result) ->
    @reporter.reportSpecResults(result)
