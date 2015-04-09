describe "Teaspoon.Mocha.Responder", ->

  newResponder = (runner, reporter) ->
    originalReporter = Teaspoon.Mocha.Responder::reporter
    Teaspoon.Mocha.Responder::reporter = reporter
    responder = new Teaspoon.Mocha.Responder(runner)
    responder.reporter = reporter
    Teaspoon.Mocha.Responder::reporter = originalReporter
    responder

  beforeEach ->
    @reportRunnerStartingDetails =
      total: 42
    @reportSuiteStartingDetails =
      title: "Mocha describe"
      fullTitle: -> "Mocha describe"
    @reportSuiteResultsDetails =
      title: "Mocha describe"
      fullTitle: -> "Mocha describe"
    @reportSpecStartingDetails =
      title: "has an it"
      fullTitle: -> "Mocha describe has an it"
      parent: @reportSuiteResultsDetails
    @reportSpecResultsDetails =
      title: "has an it"
      fullTitle: -> "Mocha describe has an it"
      state: "passed"
      parent: @reportSuiteResultsDetails

    @reporter =
      reportRunnerStarting: ->
      reportRunnerResults: ->
      reportSuiteStarting: ->
      reportSuiteResults: ->
      reportSpecStarting: ->
      reportSpecResults: ->
    @runner = {on: ->}
    @responder = newResponder(@runner, @reporter)


  describe "initialization", ->

    it "reports the runner starting", ->
      sinon.stub(@reporter, "reportRunnerStarting")

      @runner.total = 42
      newResponder(@runner, @reporter)

      expect(@reporter.reportRunnerStarting
                      .calledWith(total: 42)).to.equal(true)

      @reporter.reportRunnerStarting.restore()

    it "sets up mocha callbacks", ->
      sinon.stub(@runner, "on")

      responder = newResponder(@runner, @reporter)

      expect(@runner.on.calledWith("end", responder.runnerDone)).to.equal(true)
      expect(@runner.on.calledWith("suite", responder.suiteStarted)).to.equal(true)
      expect(@runner.on.calledWith("suite end", responder.suiteDone)).to.equal(true)
      expect(@runner.on.calledWith("test", responder.specStarted)).to.equal(true)
      expect(@runner.on.calledWith("fail", responder.specFailed)).to.equal(true)
      expect(@runner.on.calledWith("test end", responder.specFinished)).to.equal(true)


  describe "end event", ->

    it "reports the runner finishing", ->
      sinon.stub(@reporter, "reportRunnerResults")

      @responder.runnerDone()

      expect(@reporter.reportRunnerResults.calledOnce).to.equal(true)

      @reporter.reportRunnerResults.restore()


  describe "suite event", ->

    it "reports the suite finishing", ->
      sinon.stub(@reporter, "reportSuiteStarting")

      @responder.suiteStarted(@reportSuiteStartingDetails)

      suiteArg = @reporter.reportSuiteStarting.args[0][0]
      expect(suiteArg instanceof Teaspoon.Mocha.Suite).to.equal(true)
      expect(suiteArg.description).to.equal("Mocha describe")

      @reporter.reportSuiteStarting.restore()


  describe "suite end event", ->

    it "reports the suite finishing", ->
      sinon.stub(@reporter, "reportSuiteResults")

      @responder.suiteDone(@reportSuiteResultsDetails)

      suiteArg = @reporter.reportSuiteResults.args[0][0]
      expect(suiteArg instanceof Teaspoon.Mocha.Suite).to.equal(true)
      expect(suiteArg.description).to.equal("Mocha describe")

      @reporter.reportSuiteResults.restore()


  describe "test event", ->

    it "reports the spec starting", ->
      sinon.stub(@reporter, "reportSpecStarting")

      @responder.specStarted(@reportSpecStartingDetails)

      specArg = @reporter.reportSpecStarting.args[0][0]
      expect(specArg instanceof Teaspoon.Mocha.Spec).to.equal(true)
      expect(specArg.description).to.equal("has an it")

      @reporter.reportSpecStarting.restore()


  describe "test end event", ->

    it "reports the spec finishing", ->
      sinon.stub(@reporter, "reportSpecResults")

      @responder.specFinished(@reportSpecResultsDetails)

      specArg = @reporter.reportSpecResults.args[0][0]
      expect(specArg instanceof Teaspoon.Mocha.Spec).to.equal(true)
      expect(specArg.description).to.equal("has an it")

      @reporter.reportSpecResults.restore()


    it "does not report the spec finishing if it failed", ->
      sinon.stub(@reporter, "reportSpecResults")

      @reportSpecResultsDetails.state = "failed"
      @responder.specFinished(@reportSpecResultsDetails)

      expect(@reporter.reportSpecResults.called).to.equal(false)

      @reporter.reportSpecResults.restore()


  describe "fail event", ->

    it "reports the spec finishing and attaches the error details", ->
      sinon.stub(@reporter, "reportSpecResults")

      error = {message: "Bad spec or hook"}
      @responder.specFailed(@reportSpecResultsDetails, error)

      specArg = @reporter.reportSpecResults.args[0][0]
      expect(specArg instanceof Teaspoon.Mocha.Spec).to.equal(true)
      expect(specArg.description).to.equal("has an it")
      expect(specArg.errors()).to.eql([error])

      @reporter.reportSpecResults.restore()
