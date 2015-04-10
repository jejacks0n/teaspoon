#= require teaspoon/reporters/console

class Teaspoon.Jasmine2.Reporters.Console extends Teaspoon.Reporters.Console

  reportRunnerStarting: ->
    @currentAssertions = []
    @log
      type:  "runner"
      total: null
      start: JSON.parse(JSON.stringify(@start))


  reportRunnerResults: =>
    @log
      type:    "result"
      elapsed: ((new Teaspoon.Date().getTime() - @start.getTime()) / 1000).toFixed(5)
      coverage: window.__coverage__
    Teaspoon.finished = true
