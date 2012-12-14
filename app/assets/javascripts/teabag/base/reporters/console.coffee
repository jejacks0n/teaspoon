class Teabag.Reporters.Console

  constructor: ->
    @failures = 0
    @pending  = 0
    @total    = 0
    @start    = new Teabag.Date().getTime()

  reportSpecResults: (spec) ->
    @total += 1
    @spec = new Teabag.Reporters.NormalizedSpec(spec)
    result = @spec.result()
    if result.status is 'pending'
      @trackPending()
    else if result.status is 'failed'
      @trackFailure()
    else
      @log
        type:             "spec"
        suite:            @spec.suiteName
        spec:             @spec.description
        status:           result.status
        skipped:          result.skipped
        full_description: @spec.fullDescription

  trackPending: ->
    @pending += 1
    result = @spec.result()
    @log
      type:             "spec"
      suite:            @spec.suiteName
      spec:             @spec.description
      status:           result.status
      skipped:          result.skipped
      full_description: @spec.fullDescription

  trackFailure: ->
    @failures += 1
    result = @spec.result()
    for error in @spec.errors()
      @log
        type:             "spec"
        suite:            @spec.suiteName
        spec:             @spec.description
        status:           result.status
        skipped:          result.skipped
        full_description: @spec.fullDescription
        link:             @spec.link
        message:          error.message
        trace:            error.stack || error.message || "Stack Trace Unavailable"

  reportRunnerResults: =>
    @log
      type:     "results"
      total:    @total
      failures: @failures
      pending:  @pending
      elapsed:  ((new Teabag.Date().getTime() - @start) / 1000).toFixed(5)
    Teabag.finished = true



  log: (obj = {}) ->
    obj["_teabag"] = true
    console.log(JSON.stringify(obj))
