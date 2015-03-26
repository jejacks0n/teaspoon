describe "Teaspoon.Jasmine2.Responder", ->

  beforeEach ->
    @jasmineStartedDetails =
      totalSpecsDefined: 42
    @suiteStartedDetails =
      id: "suite1"
      description: "Jasmine 2 describe"
      fullName: "Jasmine 2 describe"
      failedExpectations: []
    @suiteDoneDetails =
      id: "suite1"
      description: "Jasmine 2 describe"
      fullName: "Jasmine 2 describe"
      failedExpectations: []
      status: "finished"
    @specStartedDetails =
      id: "spec0"
      description: "has an it"
      fullName: "Jasmine 2 describe has an it"
      failedExpectations: []
      passedExpectations: []
      pendingReason: ""
    @specDoneDetails =
      id: "spec0"
      description: "has an it"
      fullName: "Jasmine 2 describe has an it"
      failedExpectations: []
      passedExpectations: [
        matcherName: "toEqual"
        message: "Passed."
        passed: true
        stack: ""
      ]
      pendingReason: ""
      status: "passed"

    @reporter =
      reportRunnerStarting: ->
      reportRunnerResults: ->
      reportSuiteStarting: ->
      reportSuiteResults: ->
      reportSpecStarting: ->
      reportSpecResults: ->
    @responder = new Teaspoon.Jasmine2.Responder(@reporter)


  describe "#jasmineStarted", ->

    it "reports the runner starting", ->
      spyOn(@reporter, "reportRunnerStarting")

      @responder.jasmineStarted(@jasmineStartedDetails)

      expect(@reporter.reportRunnerStarting).toHaveBeenCalledWith(total: 42)


  describe "#jasmineDone", ->

    it "reports the runner finishing", ->
      spyOn(@reporter, "reportRunnerResults")

      @responder.jasmineDone()

      expect(@reporter.reportRunnerResults).toHaveBeenCalled()


  describe "#suiteStarted", ->

    it "reports the suite starting", ->
      spyOn(@reporter, "reportSuiteStarting")

      @responder.suiteStarted(@suiteStartedDetails)

      suiteArg = @reporter.reportSuiteStarting.calls.first().args[0]
      expect(suiteArg).toEqual(jasmine.any(Teaspoon.Jasmine2.Suite))
      expect(suiteArg.fullDescription).toEqual("Jasmine 2 describe")


  describe "#suiteDone", ->

    beforeEach ->
      @responder.currentSuite = {}


    it "reports the suite finishing", ->
      spyOn(@reporter, "reportSuiteResults")

      @responder.suiteDone(@suiteDoneDetails)

      suiteArg = @reporter.reportSuiteResults.calls.first().args[0]
      expect(suiteArg).toEqual(jasmine.any(Teaspoon.Jasmine2.Suite))
      expect(suiteArg.fullDescription).toEqual("Jasmine 2 describe")


  describe "#specStarted", ->

    beforeEach ->
      @responder.currentSuite = @suiteStartedDetails


    it "reports the spec starting", ->
      spyOn(@reporter, "reportSpecStarting")

      @responder.specStarted(@specStartedDetails)

      specArg = @reporter.reportSpecStarting.calls.first().args[0]
      expect(specArg).toEqual(jasmine.any(Teaspoon.Jasmine2.Spec))
      expect(specArg.fullDescription).toEqual("Jasmine 2 describe has an it")


  describe "#specDone", ->

    beforeEach ->
      @responder.currentSuite = @suiteStartedDetails


    it "reports the spec finishing", ->
      spyOn(@reporter, "reportSpecResults")

      @responder.specDone(@specDoneDetails)

      specArg = @reporter.reportSpecResults.calls.first().args[0]
      expect(specArg).toEqual(jasmine.any(Teaspoon.Jasmine2.Spec))
      expect(specArg.fullDescription).toEqual("Jasmine 2 describe has an it")


  describe "nested suites and specs", ->

    beforeEach ->
      spyOn(jasmine.getEnv(), "specFilter").and.returnValue(true)


    it "tracks the parent suite", ->
      # Mimicking the following setup:
      # describe "a", ->
      #   describe "b", ->
      #     it "a"
      #   describe "c", ->

      suitea = {}
      suiteb = {}
      speca = {fullName: ""}
      suitec = {}

      @responder.suiteStarted(suitea)
      @responder.suiteStarted(suiteb)
      @responder.specStarted(speca)
      @responder.specDone(speca)
      @responder.suiteDone(suiteb)
      @responder.suiteStarted(suitec)
      @responder.suiteDone(suitec)
      @responder.suiteDone(suitea)

      expect(suitea.parent).toBeUndefined()
      expect(suiteb.parent).toEqual(suitea)
      expect(speca.parent).toEqual(suiteb)
      expect(suitec.parent).toEqual(suitea)
