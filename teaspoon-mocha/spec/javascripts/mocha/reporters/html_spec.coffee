describe "Mocha Teaspoon.Reporters.HTML", ->

  beforeEach ->
    @runner = {on: @onSpy = sinon.spy()}
    @superSpy = Teaspoon.Reporters.HTML.__super__.constructor = sinon.spy()
    Teaspoon.Reporters.HTML.filter = "foo"
    @reportRunnerStartingSpy = Teaspoon.Reporters.HTML.prototype.reportRunnerStarting = sinon.spy()
    @reporter = new Teaspoon.Reporters.HTML(@runner)

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


describe "Mocha Teaspoon.Reporters.HTML.SpecView", ->

  describe "#updateState", ->

    it "calls super with the duration of the spec", ->
      # this can't be tested, I tried a lot....
      #@superSpy = Teaspoon.Reporters.HTML.SpecView.__super__.updateState = sinon.spy()
      #@buildSpy = Teaspoon.Reporters.HTML.SpecView.prototype.build = sinon.spy()
      #view = new Teaspoon.Reporters.HTML.SpecView({viewId: 1000000}, {views: []})
      #view.spec.duration = 1000
      #view.updateState("passed")
      #assert.calledWith(@superSpy, "passed", 1000)

