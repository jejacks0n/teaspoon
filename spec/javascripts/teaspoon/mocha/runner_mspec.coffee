describe "Mocha Teaspoon.Runner", ->

  beforeEach ->
    @runSpy = mocha.run = sinon.spy()
    @runner = new Teaspoon.Runner()

  describe "constructor", ->

    it "calls run on the mocha env", ->
      @runner.setup = sinon.stub()
      assert.calledOnce(@runSpy)


  describe "#setup", ->

    it "adds the reporter to the env", ->
#      spy = mocha.setup = sinon.spy()
#      @runner.params = {grep: "foo"}
#      @runner.setup()
#      if window.navigator.userAgent.match(/PhantomJS/)
#        assert.calledOnce(spy, reporter: Teaspoon.Reporters.Console)
#      else
#        assert.calledOnce(spy, reporter: Teaspoon.Reporters.HTML)
