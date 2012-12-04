describe "Teabag running Mocha", ->

  describe "running tests", ->

    it "actially tests", -> expect(passing).to.equal(true)

  describe "failing tests", ->

    it "can fail", -> expect(failing).to.equal(false)

  describe "nesting", ->

    describe "multiple levels", ->

      it "displays", -> expect(passing).to.equal(true)
