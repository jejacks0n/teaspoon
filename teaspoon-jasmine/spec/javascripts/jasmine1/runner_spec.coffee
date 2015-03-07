describe "Jasmine Teaspoon.Runner", ->

  beforeEach ->
    @env = jasmine.getEnv()
    @originalFilter = @env.specFilter
    @executeSpy = spyOn(@env, "execute")
    @runner = new Teaspoon.Runner()

  afterEach ->
    @env.specFilter = @originalFilter

  describe "constructor", ->

    it "calls execute on the jasmine env", ->
      expect(@executeSpy).toHaveBeenCalled()


  describe "#setup", ->

    beforeEach ->
      @runner.params = {grep: "foo"}
      if window.navigator.userAgent.match(/PhantomJS/)
        @reporterSpy = spyOn(Teaspoon.Reporters, "Console").andReturn(@instance)
      else
        @reporterSpy = spyOn(Teaspoon.Reporters, "HTML").andReturn(@instance)
      @addReporterSpy = spyOn(@env, "addReporter")

    it "sets the updateInterval", ->
      expect(@env.updateInterval).toEqual(1000)

    it "adds the reporter to the env", ->
      @runner.setup()
      expect(@reporterSpy).toHaveBeenCalled()
      expect(@addReporterSpy).toHaveBeenCalled()

    it "adds fixture support", ->
      spy = spyOn(@runner, "addFixtureSupport")
      @runner.setup()
      expect(spy).toHaveBeenCalled()


  describe "#addFixtureSupport", ->

    beforeEach ->
      @fixtureObj = {cleanUp: ->}
      @styleFixtureObj = {cleanUp: ->}
      @jsonFixtureSpyObj = {cleanUp: ->}
      @fixtureSpy = spyOn(jasmine, "getFixtures").andReturn(@fixtureObj)
      @styleFixtureSpy = spyOn(jasmine, "getStyleFixtures").andReturn(@styleFixtureObj)
      @jsonFixtureSpy = spyOn(jasmine, "getJSONFixtures").andReturn(@jsonFixtureSpyObj)

    it "adds fixture support", ->
      expect(jasmine.getFixtures).toBeDefined()
      @runner.fixturePath = "/path/to/fixtures"
      @runner.addFixtureSupport()
      expect(@fixtureObj.containerId).toBe("teaspoon-fixtures")
      expect(@fixtureObj.fixturesPath).toBe("/path/to/fixtures")
      expect(@styleFixtureObj.fixturesPath).toBe("/path/to/fixtures")
      expect(@jsonFixtureSpyObj.fixturesPath).toBe("/path/to/fixtures")
