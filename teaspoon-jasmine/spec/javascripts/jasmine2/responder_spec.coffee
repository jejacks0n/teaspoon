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

    it "has an it", ->
      spyOn(@reporter, 'reportRunnerStarting')

      @responder.jasmineStarted(@jasmineStartedDetails)

      expect(@reporter.reportRunnerStarting).toHaveBeenCalledWith(total: 42)


  describe "#jasmineDone", ->

    it "reports the runner finishing", ->
      spyOn(@reporter, 'reportRunnerResults')

      @responder.jasmineDone()

      expect(@reporter.reportRunnerResults).toHaveBeenCalled()


  describe "#suiteStarted", ->

    it "reports the suite starting", ->
      spyOn(@reporter, 'reportSuiteStarting')

      @responder.suiteStarted(@suiteStartedDetails)

      expect(@reporter.reportSuiteStarting).toHaveBeenCalledWith
        id: "suite1"
        description: "Jasmine 2 describe"
        fullName: "Jasmine 2 describe"


    it "does not error out if the reporter doesn't care about starting suites", ->
      delete @reporter.reportSuiteStarting

      expect(=>
        @responder.suiteStarted(@suiteStartedDetails)
      ).not.toThrow()


  describe "#suiteDone", ->

    beforeEach ->
      @responder.currentSuite = {}


    it "reports the suite finishing", ->
      spyOn(@reporter, 'reportSuiteResults')

      @responder.suiteDone(@suiteDoneDetails)

      expect(@reporter.reportSuiteResults).toHaveBeenCalledWith
        id: "suite1"
        description: "Jasmine 2 describe"
        fullName: "Jasmine 2 describe"


    it "does not error out if the reporter doesn't care about finishing suites", ->
      delete @reporter.reportSuiteResults

      expect(=>
        @responder.suiteDone(@suiteDoneDetails)
      ).not.toThrow()


  describe "#specStarted", ->

    it "reports the spec starting", ->
      spyOn(@reporter, 'reportSpecStarting')

      @responder.specStarted(@specStartedDetails)

      expect(@reporter.reportSpecStarting).toHaveBeenCalledWith
        id: "spec0"
        description: "has an it"
        fullName: "Jasmine 2 describe has an it"
        failedExpectations: []
        passedExpectations: []
        pendingReason: ""
        parent: undefined


    it "does not error out if the reporter doesn't care about starting specs", ->
      delete @reporter.reportSpecStarting

      expect(=>
        @responder.specStarted(@specStartedDetails)
      ).not.toThrow()


  describe "#specDone", ->

    it "reports the spec finishing", ->
      spyOn(@reporter, 'reportSpecResults')

      @responder.specDone(@specDoneDetails)

      expect(@reporter.reportSpecResults).toHaveBeenCalledWith
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
        parent: undefined


  describe "nested suites and specs", ->

    beforeEach ->
      spyOn(jasmine.getEnv(), 'specFilter').and.returnValue(true)


    it "tracks the parent suite", ->
      # Mimicking the following setup:
      # describe "a", ->
      #   describe "b", ->
      #     it "a"
      #   describe "c", ->

      suitea = {}
      suiteb = {}
      speca = {fullName: ''}
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
