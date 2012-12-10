class Teabag.Reporters.Console

  constructor: ->
    @fails = []
    @pending = []
    @total = 0
    @start = Date.now()


  reportSpecResults: (@spec) ->
    result = @resultForSpec()
    if result.pending
      @trackPending()
      status = "skipped"
    else if result.passed
      status = "pass"
    else
      @trackFailure()
      status = "fail"
    @total += 1
    @log(type: "spec", status: status, description: result.description)


  reportRunnerResults: =>
    @log(type: "results", total: @total, failures: @fails, pending: @pending, elapsed: ((Date.now() - @start) / 1000).toFixed(5))
    Teabag.finished = true


  resultForSpec: ->
    results = @spec.results()
    pending: @spec.pending
    skipped: results.skipped
    passed: results.passed()
    description: @spec.description


  trackFailure: ->
    for error in @errors()
      @fails.push(spec: @fullName(), description: error.message, link: @link(), trace: error.stack || error.message || "Stack Trace Unavailable")


  errors: ->
    for item in @spec.results().getItems()
      item.trace


  trackPending: ->
    @pending.push(spec: @fullName())


  fullName: ->
    @spec.getFullName()


  link: ->
    "?grep=#{encodeURIComponent(@fullName())}"


  setFilter: ->


  log: (obj = {}) ->
    obj["_teabag"] = true
    console.log(JSON.stringify(obj))
