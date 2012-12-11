class Teabag.Reporters.Console

  constructor: ->
    @failures = []
    @pending = []
    @total = 0
    @start = Date.now()


  reportSpecResults: (spec) ->
    @spec = new Teabag.Reporters.NormalizedSpec(spec)
    result = @spec.result()
    switch result.status
      when "pending" then @trackPending()
      when "failed" then @trackFailure()
    @total += 1
    @log(type: "spec", spec: @spec.description, status: result.status, skipped: result.skipped)


  reportRunnerResults: =>
    @log(type: "results", total: @total, failures: @failures, pending: @pending, elapsed: ((Date.now() - @start) / 1000).toFixed(5))
    Teabag.finished = true


  trackPending: ->
    @pending.push(spec: @spec.fullDescription)


  trackFailure: ->
    for error in @spec.errors()
      @failures.push(spec: @spec.fullDescription, link: @spec.link, message: error.message, trace: error.stack || error.message || "Stack Trace Unavailable")


  log: (obj = {}) ->
    obj["_teabag"] = true
    console.log(JSON.stringify(obj))
