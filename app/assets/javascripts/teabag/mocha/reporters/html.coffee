class Teabag.Reporters.HTML extends Teabag.Reporters.HTML

  constructor: (runner) ->
    super
    @setFilter(Teabag.Reporters.HTML.filter)
    @reportRunnerStarting(runner)
    runner.on("fail", @reportSpecResults)
    runner.on("test end", @reportSpecResults)
    runner.on("end", @reportRunnerResults)


  reportSpecResults: (spec, err) =>
    if err
      spec.err = err
      return
    @reportSpecStarting(spec)
    super


  resultForSpec: (spec) ->
    skipped: spec.pending
    passed: spec.state == "passed"


  envInfo: ->
    "mocha 1.7.3"



class Teabag.Reporters.HTML.FailureView extends Teabag.Reporters.HTML.FailureView

  fullName: ->
    @spec.fullTitle()


  errors: ->
    [@spec.err]



class Teabag.Reporters.HTML.SpecView extends Teabag.Reporters.HTML.SpecView

  fullName: ->
    @spec.fullTitle()


  description: ->
    @spec.title


  updateState: (state, elapsed) ->
    super(state, @spec.duration)


  parent: ->
    @spec.parent


  passed: ->
    @spec.state == "passed"


  errors: ->
    [@spec.err]



class Teabag.Reporters.HTML.SuiteView extends Teabag.Reporters.HTML.SuiteView

  parent: ->
    unless @suite.parent.root
      @suite.parent
    else
      null


  description: ->
    @suite.title


  fullName: ->
    @suite.fullTitle()
