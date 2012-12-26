describe "Teabag.Runner", ->

  beforeEach ->
    spyOn(jasmine.getEnv(), "execute")
    Teabag.Runner.run = false # reset this so we can use it
    @setupSpy = spyOn(Teabag.Runner.prototype, "setup")

  describe "constructor", ->

    it "calls setup", ->
      new Teabag.Runner()
      expect(@setupSpy).toHaveBeenCalled()

    it "sets Teabag.Runner.run to true", ->
      new Teabag.Runner()
      expect(Teabag.Runner.run).toEqual(true)

    it "sets @fixturePath to whatever was in Teabag.root", ->
      Teabag.root = "/path/to"
      runner = new Teabag.Runner()
      expect(runner.fixturePath).toEqual("/path/to/fixtures")

    it "doesn't call setup if already run", ->
      Teabag.Runner.run = true
      new Teabag.Runner()
      expect(@setupSpy).wasNotCalled()


  describe "#getParams", ->

    it "gets the params out of the window.location.search", ->
      spyOn(String.prototype, "substring").andReturn("grep=foo&bar=baz")
      runner = new Teabag.Runner()
      expect(runner.params).toEqual(grep: "foo", bar: "baz")


  describe "#getReporter", ->

    it "returns the correct reporter when using PhantomJS", ->
      runner = new Teabag.Runner()
      runner.params = {}
      spyOn(String.prototype, 'match').andReturn(20)
      expect(runner.getReporter()).toBe(Teabag.Reporters.Console)

    it "returns the correct reporter when using the browser", ->
      runner = new Teabag.Runner()
      runner.params = {}
      spyOn(String.prototype, 'match').andReturn(0)
      expect(runner.getReporter()).toBe(Teabag.Reporters.HTML)

    it "allows setting the param", ->
      runner = new Teabag.Runner()
      runner.params = {reporter: "Console"}
      expect(runner.getReporter()).toBe(Teabag.Reporters.Console)
      runner.params = {reporter: "HTML"}
      expect(runner.getReporter()).toBe(Teabag.Reporters.HTML)
