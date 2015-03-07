class Teaspoon.Reporters.Console extends Teaspoon.Reporters.Console

  jasmineStarted: ->
    @reportRunnerStarting()


  reportRunnerStarting: ->
    @currentAssertions = []
    @log
      type:  "runner"
      total: null
      start: JSON.parse(JSON.stringify(@start))


  jasmineDone: ->
    @reportRunnerResults()


  reportRunnerResults: =>
    @log
      type:    "result"
      elapsed: ((new Teaspoon.Date().getTime() - @start.getTime()) / 1000).toFixed(5)
      coverage: window.__coverage__
    Teaspoon.finished = true


  suiteStarted: (result) ->
    if @currentSuite # suite already running, we're nested
      result.parent = @currentSuite
    @currentSuite = result


  suiteDone: (result) ->
    @currentSuite = @currentSuite.parent


  specDone: (result) ->
    result.parent = @currentSuite
    @reportSpecResults(result)
