console.log("testing console output")

describe "Teabag running Mocha", ->

  it "is awesome", ->
    expect(passing).to.equal(true)


  describe "running tests", ->

    it "actually tests", ->
      # todo: provide similar fixture support for mocha
      #loadFixtures("fixture.html")
      #expect($("#fixture_view")).toExist()

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
