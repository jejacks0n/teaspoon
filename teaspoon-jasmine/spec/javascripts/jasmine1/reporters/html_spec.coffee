describe "Jasmine Teaspoon.Reporters.HTML", ->

  beforeEach ->
    spyOn(Teaspoon.Reporters.HTML.prototype, "build")
    @reporter = new Teaspoon.Reporters.HTML()

  describe "#readConfig", ->

    it "sets jasmine.CATCH_EXCEPTIONS", ->
      @reporter.readConfig()
      expect(jasmine.CATCH_EXCEPTIONS).toBe(@reporter.config["use-catch"])


  describe "#envInfo", ->

    it "returns jasmine version information", ->
      expect(@reporter.envInfo()).toBe("jasmine 1.3.1 revision 1354556913")
