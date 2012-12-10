#= require jquery
#= require jasmine-jquery
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

  describe "pending tests", ->

    it "allows them"

    xit "doesn't display or run", ->
      alert('no no no')
      expect(false).to.equal(true)

  describe "nesting", ->

    describe "multiple levels", ->

      it "displays correctly", ->
        expect(passing).toEqual(true)

  it "is something cool", ->
    expect(passing).toEqual(true)
