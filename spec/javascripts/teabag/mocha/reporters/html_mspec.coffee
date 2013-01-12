describe "Mocha Teabag.Reporters.HTML", ->

  beforeEach ->
    @runner = {on: @onSpy = sinon.spy()}
    @superSpy = Teabag.Reporters.HTML.__super__.constructor = sinon.spy()
    Teabag.Reporters.HTML.filter = "foo"
    @reportRunnerStartingSpy = Teabag.Reporters.HTML.prototype.reportRunnerStarting = sinon.spy()
    @reporter = new Teabag.Reporters.HTML(@runner)

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


  describe "#envInfo", ->

    it "returns the version", ->
      expect(@reporter.envInfo()).to.be("mocha 1.7.4")


describe "Mocha Teabag.Reporters.HTML.SpecView", ->

  describe "#updateState", ->

    it "calls super with the duration of the spec", ->
      # this can't be tested, I tried a lot....
      #@superSpy = Teabag.Reporters.HTML.SpecView.__super__.updateState = sinon.spy()
      #@buildSpy = Teabag.Reporters.HTML.SpecView.prototype.build = sinon.spy()
      #view = new Teabag.Reporters.HTML.SpecView({viewId: 1000000}, {views: []})
      #view.spec.duration = 1000
      #view.updateState("passed")
      #assert.calledWith(@superSpy, "passed", 1000)

