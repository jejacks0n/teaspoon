describe "Teaspoon.Jasmine1.Suite", ->

  beforeEach ->
    @mockParentSuite = {}
    @mockSuite =
      description: "_jasmine_description_"
      parentSuite: @mockParentSuite
      viewId: 42
      getFullName: -> "_full jasmine description_"

  describe "constructor", ->

    it "has the expected properties", ->
      suite = new Teaspoon.Jasmine1.Suite(@mockSuite)
      expect(suite.fullDescription).toBe("_full jasmine description_")
      expect(suite.description).toBe("_jasmine_description_")
      expect(suite.link).toBe("?grep=_full%20jasmine%20description_")
      expect(suite.parent).toBe(@mockParentSuite)
      expect(suite.viewId).toBe(42)
