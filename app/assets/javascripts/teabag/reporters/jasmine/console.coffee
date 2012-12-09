class Teabag.Reporters.Console
  fails = []
  total = 0

  constructor: ->
    @start = Date.now()


  reportSpecResults: (spec) ->
    if spec.results().passed()
      status = "pass"
    else if spec.results.skipped
      status = "skipped"
    else
      @trackFailure(spec)
      status = "fail"
    total += 1
    @log(type: "spec", status: status, description: spec.description, suite: spec.suite.getFullName())


  reportRunnerResults: ->
    @log(type: "results", total: total, failures: fails, elapsed: ((Date.now() - @start) / 1000).toFixed(5))
    Teabag.finished = true


  trackFailure: (spec) ->
    for item in spec.results().getItems()
      fails.push(spec: spec.getFullName(), description: item.toString(), link: "?grep=#{encodeURIComponent(spec.getFullName())}", trace: item.trace.stack || item.trace.toString())


  log: (object = {}) ->
    object["_teabag"] = true
    console.log(JSON.stringify(object))
