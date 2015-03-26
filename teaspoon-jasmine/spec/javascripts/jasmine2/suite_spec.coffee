describe "Teaspoon.Jasmine2.Suite", ->

  beforeEach ->
    @mockParentSuite = {}
    @mockSuite =
      id: "42"
      fullName: "_full jasmine description_"
      description: "_jasmine_description_"
      failedExpectations: []
      parent: @mockParentSuite
      status: "finished"

  describe "constructor", ->

    it "has the expected properties", ->
      suite = new Teaspoon.Suite(@mockSuite)
      expect(suite.fullDescription).toBe("_full jasmine description_")
      expect(suite.description).toBe("_jasmine_description_")
      expect(suite.link).toBe("?grep=_full%20jasmine%20description_")
      expect(suite.parent).toBe(@mockParentSuite)
      expect(suite.viewId).toBe("42")
