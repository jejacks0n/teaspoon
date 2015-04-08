class Teaspoon.Jasmine1.Responder

  constructor: (@reporter) ->

  
  reportRunnerStarting: (runner) ->
    @reporter.reportRunnerStarting(total: runner.specs().length)

  
  reportRunnerResults: ->
    @reporter.reportRunnerResults()


  reportSuiteResults: (suite) ->
    @reporter.reportSuiteResults(new Teaspoon.Jasmine1.Suite(suite))


  reportSpecStarting: (spec) ->
    @reporter.reportSpecStarting(new Teaspoon.Jasmine1.Spec(spec))


  reportSpecResults: (spec) ->
    @reporter.reportSpecResults(new Teaspoon.Jasmine1.Spec(spec))
