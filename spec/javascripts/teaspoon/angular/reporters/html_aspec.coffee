describe "Angular Teaspoon.Reporters.HTML", ->

  beforeEach ->
    @reporter = new Teaspoon.Reporters.HTML()

  describe "#envInfo", ->

    it "return angular version information", ->
      _expect(@reporter.envInfo()).toBe("angular-scenario 1.0.5")
