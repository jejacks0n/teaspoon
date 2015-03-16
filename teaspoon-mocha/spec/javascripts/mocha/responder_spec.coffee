#describe "Teaspoon.Mocha.Responder", ->
#
#  beforeEach ->
#    @reportRunnerStartingDetails =
#      total: 42
#    @reportSuiteStartingDetails =
#      title: "Mocha describe"
#      fullTitle: -> "Mocha describe"
#    @reportSuiteResultsDetails =
#      title: "Mocha describe"
#      fullTitle: -> "Mocha describe"
#    @reportSpecStartingDetails =
#      title: "has an it"
#      fullTitle: -> "Mocha describe has an it"
#      parent: @reportSuiteResultsDetails
#    @reportSpecResultsDetails =
#      title: "has an it"
#      fullTitle: -> "Mocha describe has an it"
#      state: "passed"
#      parent: @reportSuiteResultsDetails
#
#    @reporter = Teaspoon.Mocha.Responder::reporter
#    @runner = new Mocha.Runner(new Mocha.Suite)
#    @responder = new Teaspoon.Mocha.Responder(@runner)
#
#
#  describe "initialization", ->
#
#    it "reports the runner starting", ->
#      sinon.spy(@reporter, "reportRunnerStarting")
#
#      @runner.total = 42
#      new Teaspoon.Mocha.Responder(@runner)
#
#      expect(@reporter.reportRunnerStarting
#                      .calledWith(total: 42)).to.equal(true)
#
#      @reporter.reportRunnerStarting.restore()
#
#
#  describe "end event", ->
#
#    it "reports the runner finishing", ->
#      sinon.spy(@reporter, "reportRunnerResults")
#
#      @runner.emit("end")
#
#      expect(@reporter.reportRunnerResults.calledOnce).to.equal(true)
#
#      @reporter.reportRunnerResults.restore()
#
#
#  describe "suite event", ->
#
#    it "reports the suite finishing", ->
#      sinon.spy(@reporter, "reportSuiteStarting")
#
#      @runner.emit("suite", @reportSuiteStartingDetails)
#
#      expect(@reporter.reportSuiteStarting.calledOnce).to.equal(true)
#
#      @reporter.reportSuiteStarting.restore()
#
#
#  describe "suite end event", ->
#
#    it "reports the suite finishing", ->
#      sinon.spy(@reporter, "reportSuiteResults")
#
#      @runner.emit("suite end", @reportSuiteResultsDetails)
#
#      expect(@reporter.reportSuiteResults.calledOnce).to.equal(true)
#
#      @reporter.reportSuiteResults.restore()
#
#
#  describe "test event", ->
#
#    it "reports the spec starting", ->
#      sinon.spy(@reporter, "reportSpecStarting")
#
#      @runner.emit("test", @reportSpecStartingDetails)
#
#      expect(@reporter.reportSpecStarting
#                      .calledWith(@reportSpecStartingDetails)).to.equal(true)
#
#      @reporter.reportSpecStarting.restore()
#
#
#  describe "pass event", ->
#
#    it "reports the spec finishing", ->
#      sinon.spy(@reporter, "reportSpecResults")
#
#      @runner.emit("pass", @reportSpecResultsDetails)
#
#      expect(@reporter.reportSpecResults
#                      .calledWith(@reportSpecResultsDetails)).to.equal(true)
#
#      @reporter.reportSpecResults.restore()
#
#
#  describe "fail event", ->
#
#    it "reports the spec finishing and attaches the error details", ->
#      sinon.spy(@reporter, "reportSpecResults")
#
#      error = {message: "Bad spec or hook"}
#      @runner.emit("fail", @reportSpecResultsDetails, error)
#
#      @reportSpecResultsDetails.err = error
#      expect(@reporter.reportSpecResults
#                      .calledWith(@reportSpecResultsDetails)).to.equal(true)
#
#      @reporter.reportSpecResults.restore()
