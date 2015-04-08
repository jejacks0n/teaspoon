describe "Teaspoon.Jasmine1.Responder", ->

  beforeEach ->
    @reportRunnerStartingDetails =
      specs: -> {length: 42}
    @reportSuiteResultsDetails =
      id: 0
      description: "Jasmine 1 describe"
      getFullName: -> "Jasmine 1 describe"
    @reportSpecStartingDetails =
      id: 1
      getFullName: -> "Jasmine 1 describe has an it"
      description: "has an it"
      suite: @reportSuiteResultsDetails
    @reportSpecResultsDetails =
      id: 1
      getFullName: -> "Jasmine 1 describe has an it"
      description: "has an it"
      suite: @reportSuiteResultsDetails

    @reporter =
      reportRunnerStarting: ->
      reportRunnerResults: ->
      reportSuiteStarting: ->
      reportSuiteResults: ->
      reportSpecStarting: ->
      reportSpecResults: ->
    @responder = new Teaspoon.Jasmine1.Responder(@reporter)


  describe "#reportRunnerStarting", ->

    it "reports the runner starting", ->
      spyOn(@reporter, 'reportRunnerStarting')

      @responder.reportRunnerStarting(@reportRunnerStartingDetails)

      expect(@reporter.reportRunnerStarting).toHaveBeenCalledWith(total: 42)


  describe "#reportRunnerResults", ->

    it "reports the runner finishing", ->
      spyOn(@reporter, 'reportRunnerResults')

      @responder.reportRunnerResults()

      expect(@reporter.reportRunnerResults).toHaveBeenCalled()


  describe "#reportSuiteResults", ->

    it "reports the suite finishing", ->
      spyOn(@reporter, 'reportSuiteResults')

      @responder.reportSuiteResults(@reportSuiteResultsDetails)

      suiteArg = @reporter.reportSuiteResults.calls[0].args[0]
      expect(suiteArg).toEqual(jasmine.any(Teaspoon.Jasmine1.Suite))
      expect(suiteArg.fullDescription).toEqual("Jasmine 1 describe")


  describe "#reportSpecStarting", ->

    it "reports the spec starting", ->
      spyOn(@reporter, 'reportSpecStarting')

      @responder.reportSpecStarting(@reportSpecStartingDetails)

      specArg = @reporter.reportSpecStarting.calls[0].args[0]
      expect(specArg).toEqual(jasmine.any(Teaspoon.Jasmine1.Spec))
      expect(specArg.fullDescription).toEqual("Jasmine 1 describe has an it")


  describe "#reportSpecResults", ->

    it "reports the spec finishing", ->
      spyOn(@reporter, 'reportSpecResults')

      @responder.reportSpecResults(@reportSpecResultsDetails)

      specArg = @reporter.reportSpecResults.calls[0].args[0]
      expect(specArg).toEqual(jasmine.any(Teaspoon.Jasmine1.Spec))
      expect(specArg.fullDescription).toEqual("Jasmine 1 describe has an it")
