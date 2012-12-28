console.log("testing console output")

describe "Teabag running Jasmine", ->

  it "is awesome", ->
    expect(passing).toEqual(true)


  describe "running tests", ->

    it "actually tests", ->
      loadFixtures("fixture.html")
      expect($("#fixture_view")).toExist()

    it "can handle more than one test", ->
      waits(1000)
      runs -> expect(passing).toEqual(true)


  describe "failing tests", ->

    it "can fail", ->
      expect(failing).toEqual(false)


  describe "pending", ->

    it "is allowed"

    xit "doesn't display or get executed (different than mocha)", ->
      alert("no no no")
      expect(false).to.equal(true)


  describe "nesting", ->

    describe "multiple levels", ->

      it "displays correctly", ->
        expect(passing).toEqual(true)


  it "is something cool", ->
    expect(passing).toEqual(true)



fixture.preload("fixture.html", "fixture.json") # make the actual requests for the files
describe "Using fixtures", ->

  fixture.set("<h2>Another Title</h2>") # create some markup manually (will be in a beforeEach)

  beforeEach ->
    @fixtures = fixture.load("fixture.html", "fixture.json", true) # append these fixtures

  it "loads fixtures", ->
    expect($("h1", fixture.el).text()).toBe("Title") # using fixture.el as a jquery scope
    expect($("h2", fixture.el).text()).toBe("Another Title")
    expect(@fixtures[0]).toBe(fixture.el) # the element is available as a return value and through fixture.el
    expect(@fixtures[1]).toEqual(fixture.json[0]) # the json for json fixtures is returned, and available in fixture.json
