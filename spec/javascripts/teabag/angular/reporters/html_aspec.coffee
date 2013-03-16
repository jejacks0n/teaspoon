describe "Angular Teabag.Reporters.HTML", ->

  beforeEach ->
    @reporter = new Teabag.Reporters.HTML()

  describe "#envInfo", ->

    it "return angular version information", ->
      _expect(@reporter.envInfo()).toBe("angular-scenario 1.0.5")
