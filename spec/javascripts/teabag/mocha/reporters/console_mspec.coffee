describe "Mocha Teabag.Reporters.Console", ->

  beforeEach ->
    @runner = {on: @onSpy = sinon.spy()}
    @reporter = new Teabag.Reporters.Console(@runner)

  describe "constructor", ->

    it "registers for 'fail', 'test end', and 'end'", ->
      assert.calledWith(@onSpy, "fail", @reporter.reportSpecResults)
      assert.calledWith(@onSpy, "test end", @reporter.reportSpecResults)
      assert.calledWith(@onSpy, "end", @reporter.reportRunnerResults)


  describe "#reportSpecResults", ->

    it "sets the error if one is passed in", ->
      spec = {}
      @reporter.reportSpecResults(spec, foo: "bar")
      expect(spec.err).to.eql(foo: "bar")
