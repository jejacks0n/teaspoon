describe "Teaspoon.Jasmine2.Reporters.HTML", ->

  beforeEach ->
    spyOn(Teaspoon.Reporters.HTML.prototype, "build")
    @reporter = new Teaspoon.Jasmine2.Reporters.HTML()

  describe "#readConfig", ->

    it "sets jasmine.CATCH_EXCEPTIONS", ->
      @reporter.readConfig()
      expect(jasmine.CATCH_EXCEPTIONS).toBe(@reporter.config["use-catch"])


  describe "#envInfo", ->

    it "returns jasmine version information", ->
      expect(@reporter.envInfo()).toBe("jasmine 2.2.0")
