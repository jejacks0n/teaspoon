describe "Teabag", ->

  describe "class level API", ->

    it "has the expected API", ->
      expect(Object.keys(Teabag)).toEqual([
        "defer", "slow", "fixturePath", "finished", "Reporters", "execute", "Runner"
      ])

  describe "@execute", ->

    beforeEach ->
      Teabag.defer = false

    it "allows defering (thus not instantiating the runner)", ->
      Teabag.defer = true
      spy = spyOn(Teabag, "Runner")
      Teabag.execute()
      expect(spy).wasNotCalled()

    it "will execute if it should", ->
      spy = spyOn(Teabag, "Runner")
      Teabag.execute()
      expect(spy).toHaveBeenCalled()
