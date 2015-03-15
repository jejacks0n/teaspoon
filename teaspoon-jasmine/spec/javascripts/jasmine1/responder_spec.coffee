describe "Teaspoon.Jasmine.Responder", ->

  beforeEach ->
    @reportRunnerStartingDetails =
      specs: -> {length: 42}
    @reportSuiteResultsDetails =
      id: 0
      description: "Jasmine 1 describe"
      getFullName: -> "Jasmine 1 describe"
    @reportSpecStartingDetails =
      id: 1
      getFullName: -> "Jasmine 2 describe has an it"
      description: "has an it"
      suite: @reportSuiteResultsDetails
    @reportSpecResultsDetails =
      id: 1
      getFullName: -> "Jasmine 2 describe has an it"
      description: "has an it"
      suite: @reportSuiteResultsDetails

    @reporter =
      reportRunnerStarting: ->
      reportRunnerResults: ->
      reportSuiteStarting: ->
      reportSuiteResults: ->
      reportSpecStarting: ->
      reportSpecResults: ->
    @responder = new Teaspoon.Jasmine.Responder(@reporter)


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

      expect(@reporter.reportSuiteResults).toHaveBeenCalledWith
        id: 0
        description: "Jasmine 1 describe"
        fullName: "Jasmine 1 describe"


  describe "#reportSpecStarting", ->

    it "reports the spec starting", ->
      spyOn(@reporter, 'reportSpecStarting')

      @responder.reportSpecStarting(@reportSpecStartingDetails)

      expect(@reporter.reportSpecStarting).toHaveBeenCalledWith(@reportSpecStartingDetails)


  describe "#reportSpecResults", ->

    it "reports the spec finishing", ->
      spyOn(@reporter, 'reportSpecResults')

      @responder.reportSpecResults(@reportSpecResultsDetails)

      expect(@reporter.reportSpecResults).toHaveBeenCalledWith(@reportSpecResultsDetails)
