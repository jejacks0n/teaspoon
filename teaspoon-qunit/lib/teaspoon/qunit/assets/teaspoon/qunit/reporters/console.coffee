class Teaspoon.Reporters.Console extends Teaspoon.Reporters.Console

  constructor: (env) ->
    super
    env.log(@reportSpecResults)
    env.testDone(@reportSpecResults)
    env.done(@reportRunnerResults)
    @reportRunnerStarting()


  reportRunnerStarting: ->
    @currentAssertions = []
    @log
      type:  "runner"
      total: null
      start: JSON.parse(JSON.stringify(@start))


  reportSpecResults: (result) =>
    unless typeof(result.total) == "number"
      @currentAssertions.push(result)
      return
    result.assertions = @currentAssertions
    @currentAssertions = []
    super(result)
