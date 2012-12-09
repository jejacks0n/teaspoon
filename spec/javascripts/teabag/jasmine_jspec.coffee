describe "Teabag running Jasmine", ->

  it "is awesome", -> expect(passing).toEqual(true)
  it "is something", -> expect(passing).toEqual(true)


  describe "running tests", ->

    it "actually tests", ->
      expect(passing).toEqual(true)

    it "has more than one test", ->
      waits(1000)
      runs -> expect(passing).toEqual(true)

  describe "failing tests", ->

    it "can fail", ->
      waits(1000)
      runs ->
        expect(failing).toEqual(false)


  describe "nesting", ->

    describe "multiple levels", ->

      it "displays", ->
        waits(1000)
        runs -> expect(passing).toEqual(true)

