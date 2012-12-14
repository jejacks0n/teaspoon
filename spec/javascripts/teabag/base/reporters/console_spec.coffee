describe "Teabag.Reporters.Console", ->

  beforeEach ->
    @logSpy = spyOn(window.console, "log")
    spyOn(Date, "now").andReturn(666)

    @spec =
      fullDescription:  "_spec_description_"
      description:      "_spec_name_"
      suiteName:        "_suite_name_"
      link: "?grep=_spec_description_"
      result: -> {status: "passed", skipped: false}
      errors: -> [{message: "_message_", trace: {stack: "_stack_"}}]

    @reporter = new Teabag.Reporters.Console()
    @reporter.spec = @spec
    @normalizeSpy = spyOn(Teabag.Reporters, "NormalizedSpec").andReturn(@spec)


  describe "constructor", ->

    it "tracks failures, pending, total, and start time", ->
      expect(@reporter.failures).toEqual(0)
      expect(@reporter.pending).toEqual(0)
      expect(@reporter.total).toEqual(0)
      expect(@reporter.start).toBeDefined()


  describe "#reportSpecResults", ->

    it "normalizes the spec", ->
      @reporter.reportSpecResults()
      expect(@normalizeSpy).toHaveBeenCalled()

    it "adds to the total", ->
      @reporter.reportSpecResults()
      expect(@reporter.total).toEqual(1)

    it "logs the information", ->
      spy = spyOn(@reporter, "log")
      @reporter.reportSpecResults()
      expect(spy).toHaveBeenCalledWith
        type:             "spec"
        spec:             "_spec_name_"
        suite:            "_suite_name_"
        status:           "passed"
        skipped:          false
        full_description: "_spec_description_"

    describe "pending tests", ->

      beforeEach ->
        @trackSpy = spyOn(@reporter, "trackPending")
        @spec.result = -> {status: "pending", skipped: false}

      it "tracks that it was pending", ->
        @reporter.reportSpecResults()
        expect(@trackSpy).toHaveBeenCalled()

    describe "failing tests", ->

      beforeEach ->
        @trackSpy = spyOn(@reporter, "trackFailure")
        @spec.result = -> {status: "failed", skipped: false}

      it "tracks the failure", ->
        @reporter.reportSpecResults()
        expect(@trackSpy).toHaveBeenCalled()


  describe "#reportRunnerResults", ->

    it "logs the results", ->
      spy = spyOn(@reporter, "log")
      @reporter.reportRunnerResults()
      Teabag.finished = false # race condition? - this may catch and think the results are done
      args = spy.mostRecentCall.args[0]
      expect(args['type']).toEqual("results")
      expect(args['total']).toEqual(0)
      expect(args['failures']).toEqual(@reporter.failures)
      expect(args['pending']).toEqual(@reporter.pending)

    it "tells Teabag that we're finished", ->
      @reporter.reportRunnerResults()
      expect(Teabag.finished).toEqual(true)
      Teabag.finished = false # race condition? - this may catch and think the results are done


  describe "#trackPending", ->
    beforeEach ->
      @reporter.spec = @spec
      @spec.result = -> {status: "pending", skipped: false}

    it "increments the pending count", ->
      @reporter.trackPending()
      expect(@reporter.pending).toEqual(1)

    it "logs the status as 'pending'", ->
      spy = spyOn(@reporter, "log")
      @reporter.trackPending()
      expect(spy).toHaveBeenCalledWith
        type:             "spec"
        suite:            "_suite_name_"
        spec:             "_spec_name_"
        status:           "pending"
        skipped:          false
        full_description: "_spec_description_"


  describe "#trackFailure", ->
    beforeEach ->
      @reporter.spec = @spec
      @spec.result = -> {status: "failed", skipped: false}

    it "increments the failure count", ->
      @reporter.trackFailure()
      expect(@reporter.failures).toEqual(1)

    it "logs the status as 'failed'", ->
      spy = spyOn(@reporter, "log")
      @reporter.trackFailure()
      expect(spy).toHaveBeenCalledWith
        type:             "spec"
        suite:            "_suite_name_"
        spec:             "_spec_name_"
        status:           "failed"
        skipped:          false
        link:             "?grep=_spec_description_"
        message:          "_message_"
        trace:            "_message_"
        full_description: "_spec_description_"


  describe "#log", ->

    it "logs the JSON of the object passed (with an additional _teabag property)", ->
      @reporter.log(foo: true)
      expect(@logSpy).toHaveBeenCalledWith('{"foo":true,"_teabag":true}')
