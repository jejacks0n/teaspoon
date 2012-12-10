class Teabag.Reporters.Console

  constructor: ->
    @fails = []
    @total = 0
    @start = Date.now()


  reportSpecResults: (spec) ->
    result = @resultForSpec(spec)
    if spec.pending
      status = "skipped"
    else if result.passed
      status = "pass"
    else
      @trackFailure(spec)
      status = "fail"
    @total += 1
    @log(type: "spec", status: status, description: result.description)


  reportRunnerResults: =>
    @log(type: "results", total: @total, failures: @fails, elapsed: ((Date.now() - @start) / 1000).toFixed(5))
    Teabag.finished = true


  resultForSpec: (spec) ->
    results = spec.results()
    skipped: results.skipped
    passed: results.passed()
    description: spec.description


  trackFailure: (spec) ->
    for item in spec.results().getItems()
      @fails.push(spec: spec.getFullName(), description: item.toString(), link: @paramsFor(spec.getFullName()), trace: item.trace.stack || item.trace.toString())


  paramsFor: (description) ->
    "?grep=#{encodeURIComponent(description)}"


  setFilter: ->


  log: (obj = {}) ->
    obj["_teabag"] = true
    console.log(JSON.stringify(obj))

