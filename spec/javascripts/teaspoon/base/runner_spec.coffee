describe "Teaspoon.Runner", ->

  beforeEach ->
    spyOn(jasmine.getEnv(), "execute")
    Teaspoon.Runner.run = false # reset this so we can use it
    @setupSpy = spyOn(Teaspoon.Runner.prototype, "setup")

  describe "constructor", ->

    it "calls setup", ->
      new Teaspoon.Runner()
      expect(@setupSpy).toHaveBeenCalled()

    it "sets Teaspoon.Runner.run to true", ->
      new Teaspoon.Runner()
      expect(Teaspoon.Runner.run).toEqual(true)

    it "sets @fixturePath to whatever was in Teaspoon.root", ->
      originalRoot = Teaspoon.root
      Teaspoon.root = "/path/to"
      runner = new Teaspoon.Runner()
      expect(runner.fixturePath).toEqual("/path/to/fixtures")
      Teaspoon.root = originalRoot

    it "doesn't call setup if already run", ->
      Teaspoon.Runner.run = true
      new Teaspoon.Runner()
      expect(@setupSpy).wasNotCalled()


  describe "#getReporter", ->

    beforeEach ->
      @originalParams = Teaspoon.params

    afterEach ->
      Teaspoon.params = @originalParams

    it "returns the correct reporter when using PhantomJS", ->
      runner = new Teaspoon.Runner()
      Teaspoon.params = {}
      spyOn(String.prototype, 'match').andReturn(20)
      expect(runner.getReporter()).toBe(Teaspoon.Reporters.Console)

    it "returns the correct reporter when using the browser", ->
      runner = new Teaspoon.Runner()
      Teaspoon.params = {}
      spyOn(String.prototype, 'match').andReturn(0)
      expect(runner.getReporter()).toBe(Teaspoon.Reporters.HTML)

    it "allows setting the param", ->
      runner = new Teaspoon.Runner()
      Teaspoon.params = {reporter: "Console"}
      expect(runner.getReporter()).toBe(Teaspoon.Reporters.Console)
      Teaspoon.params = {reporter: "HTML"}
      expect(runner.getReporter()).toBe(Teaspoon.Reporters.HTML)
