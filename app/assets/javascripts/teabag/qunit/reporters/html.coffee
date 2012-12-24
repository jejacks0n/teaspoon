class Teabag.Reporters.HTML extends Teabag.Reporters.HTML

  constructor: (env) ->
    super
    env.log (result) => @reportSpecResults(result)
    env.done (result) => @reportRunnerResults(result)
    @reportRunnerStarting()


  reportRunnerStarting: ->
    @total.exist = null
    @setText("stats-duration", "...")


  reportSpecResults: (spec) ->
    @reportSpecStarting(spec)
    super


  reportRunnerResults: (result) ->
    @total.exist = result.total
    super


  envInfo: ->
    "qunit 1.10.0"
