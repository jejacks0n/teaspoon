class Teabag.Reporters.Console

  constructor: ->
    @start = new Teabag.Date().getTime()


  reportSpecResults: (spec) ->
    @spec = new Teabag.Reporters.NormalizedSpec(spec)
    result = @spec.result()
    switch result.status
      when "pending" then @trackPending()
      when "failed" then @trackFailure()
      else
        @log
          type:             "spec"
          suite:            @spec.suiteName
          spec:             @spec.description
          status:           result.status
          skipped:          result.skipped
          full_description: @spec.fullDescription


  trackPending: ->
    result = @spec.result()
    @log
      type:             "spec"
      suite:            @spec.suiteName
      spec:             @spec.description
      status:           result.status
      skipped:          result.skipped
      full_description: @spec.fullDescription


  trackFailure: ->
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
      elapsed:  ((new Teabag.Date().getTime() - @start) / 1000).toFixed(5)
    Teabag.finished = true


  log: (obj = {}) ->
    obj["_teabag"] = true
    console.log(JSON.stringify(obj))
