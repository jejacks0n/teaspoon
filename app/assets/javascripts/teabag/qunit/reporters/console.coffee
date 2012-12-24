class Teabag.Reporters.Console extends Teabag.Reporters.Console

  constructor: (env) ->
    super
    env.log (result) => @reportSpecResults(result)
    env.done(@reportRunnerResults)
    @reportRunnerStarting()


  reportRunnerStarting: ->
    @log
      type:  "runner"
      total: null
      start: JSON.parse(JSON.stringify(@start))
