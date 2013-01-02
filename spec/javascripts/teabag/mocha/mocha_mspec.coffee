console.log("testing console output")

describe "Teabag running Mocha", ->

  it "is awesome", ->
    expect(passing).to.equal(true)


  describe "running tests", ->

    it "actually tests", ->
      fixture("fixture.html")
#      expect(document.getElementById("fixture_view").tagName).to.be("DIV")

    it "can handle more than one test", (done) ->
      test = ->
        expect(passing).to.equal(true)
        done()
      setTimeout(test, 1000)


  describe "failing tests", ->

    it "can fail", ->
      expect(failing).to.equal(false)


  describe "pending", ->

    it "is allowed"

    xit "doesn't get executed", ->
      alert("no no no")
      expect(false).to.equal(true)


  describe "nesting", ->

    describe "multiple levels", ->

      it "displays correctly", ->
        expect(passing).to.equal(true)


  it "is something cool", ->
    expect(passing).to.equal(true)


fixture.preload("fixture.html", "fixture.json") # make the actual requests for the files
describe "Using fixtures", ->

  fixture.set("<h2>Another Title</h2>") # create some markup manually (will be in a beforeEach)

  beforeEach ->
    @fixtures = fixture.load("fixture.html", "fixture.json", true) # append these fixtures

  it "loads fixtures", ->
    expect(document.getElementById("fixture_view").tagName).to.be("DIV")
    expect(@fixtures[0]).to.be(fixture.el) # the element is available as a return value and through fixture.el
    expect(@fixtures[1]).to.eql(fixture.json[0]) # the json for json fixtures is returned, and available in fixture.json
