describe "Teabag", ->

  describe "class level API", ->

    it "has the expected API", ->
      return unless Object.keys # can't test in ie
      keys = Object.keys(Teabag)
      # common
      expect(keys).toContain("defer")
      expect(keys).toContain("slow")
      expect(keys).toContain("root")
      expect(keys).toContain("finished")
      expect(keys).toContain("execute")
      expect(keys).toContain("version")
      # caching
      expect(keys).toContain("Date")
      expect(keys).toContain("location")


  describe ".execute", ->

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
