describe "Mocha Teabag.Reporters.Console", ->

  beforeEach ->
    @runner = {on: @onSpy = sinon.spy()}
    @reportRunnerStartingSpy = Teabag.Reporters.Console.prototype.reportRunnerStarting = sinon.spy()
    @reporter = new Teabag.Reporters.Console(@runner)

  describe "constructor", ->

    it "calls reporterRunnerStarting", ->
      assert.calledOnce(@reportRunnerStartingSpy, "foo")

    it "registers for 'fail', 'test end', and 'end'", ->
      assert.calledWith(@onSpy, "fail", @reporter.reportSpecResults)
      assert.calledWith(@onSpy, "test end", @reporter.reportSpecResults)
      assert.calledWith(@onSpy, "end", @reporter.reportRunnerResults)


  describe "#reportSpecResults", ->

    it "sets the error if one is passed in", ->
      spec = {}
      @reporter.reportSpecResults(spec, foo: "bar")
      expect(spec.err).to.eql(foo: "bar")
