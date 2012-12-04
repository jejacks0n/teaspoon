describe "Teabag running Jasmine", ->

  describe "running tests", ->

    it "actially tests", -> expect(passing).toEqual(true)

  describe "failing tests", ->

    it "can fail", -> expect(failing).toEqual(false)

  describe "nesting", ->

    describe "multiple levels", ->

      it "displays", -> expect(passing).toEqual(true)
