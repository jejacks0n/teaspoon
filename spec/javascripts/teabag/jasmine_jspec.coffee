#= require jquery
#= require jasmine-jquery
describe "Teabag running Jasmine", ->

  it "is awesome", -> expect(passing).toEqual(true)

  describe "running tests", ->

    it "actually tests", ->
      loadFixtures('fixture.html')
      expect($('#fixture_view')).toExist()

    it "can handle more than one test", ->
      waits(1000)
      runs -> expect(passing).toEqual(true)

  describe "failing tests", ->

    it "can fail", ->
      expect(failing).toEqual(false)

  describe "nesting", ->

    describe "multiple levels", ->

      it "displays correctly", ->
        expect(passing).toEqual(true)
