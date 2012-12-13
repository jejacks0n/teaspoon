#describe "Mocha Teabag.Reporters.HTML", ->
#
#  beforeEach ->
#    @runner = {on: @onSpy = sinon.spy()}
#    @superSpy = Teabag.Reporters.HTML.__super__.constructor = sinon.spy()
#    Teabag.Reporters.HTML.filter = "foo"
#    @setFilterSpy = Teabag.Reporters.HTML.prototype = sinon.spy()
#    @reporter = new Teabag.Reporters.HTML(@runner)
#
#  describe "constructor", ->
#
#    it "calls setFilter", ->
#      assert.calledWith(@setFilterSpy, "foo")
#
#
##    it "calls reporterRunnerStarting"
#
#    it "registers for 'fail', 'test end', and 'end'", ->
#      assert.calledWith(@onSpy, "fail", @reporter.reportSpecResults)
#      assert.calledWith(@onSpy, "test end", @reporter.reportSpecResults)
#      assert.calledWith(@onSpy, "end", @reporter.reportRunnerResults)
#
##
##  describe "reportSpecResults", ->
##
##    it "sets the error if one is passed in", ->
##      spec = {}
##      @reporter.reportSpecResults(spec, foo: "bar")
##      expect(spec.err).to.eql(foo: "bar")
