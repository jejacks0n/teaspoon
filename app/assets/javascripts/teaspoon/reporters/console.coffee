class Teaspoon.Reporters.Console

  constructor: ->
    @start = new Teaspoon.Date()
    @suites = {}


  reportRunnerStarting: (runner) ->
    @log
      type:  "runner"
      total: runner.total || runner.specs?().length || 0
      start: JSON.parse(JSON.stringify(@start))


  reportRunnerResults: =>
    @log
      type:    "result"
      elapsed: ((new Teaspoon.Date().getTime() - @start.getTime()) / 1000).toFixed(5)
      coverage: window.__coverage__
    Teaspoon.finished = true


  reportSuiteStarting: (suite) -> # noop


  reportSuiteResults: (suite) -> # noop


  reportSpecStarting: (spec) -> # noop


  reportSuites: ->
    for suite, index in @spec.getParents()
      continue if @suites[suite.fullDescription]
      @suites[suite.fullDescription] = true
      @log
        type:  "suite"
        label: suite.description
        level: index


  reportSpecResults: (@spec) ->
    result = @spec.result()
    return if result.skipped
    @reportSuites()
    switch result.status
      when "pending" then @trackPending()
      when "failed" then @trackFailure()
      else
        @log
          type:    "spec"
          suite:   @spec.suiteName
          label:   @spec.description
          status:  result.status
          skipped: result.skipped


  trackPending: ->
    result = @spec.result()
    @log
      type:    "spec"
      suite:   @spec.suiteName
      label:   @spec.description
      status:  result.status
      skipped: result.skipped


  trackFailure: ->
    result = @spec.result()
    for error in @spec.errors()
      @log
        type:    "spec"
        suite:   @spec.suiteName
        label:   @spec.description
        status:  result.status
        skipped: result.skipped
        link:    @spec.fullDescription
        message: error.message
        trace:   error.stack || error.message || "Stack Trace Unavailable"


  log: (obj = {}) ->
    obj["_teaspoon"] = true
    Teaspoon.log(JSON.stringify(obj))
