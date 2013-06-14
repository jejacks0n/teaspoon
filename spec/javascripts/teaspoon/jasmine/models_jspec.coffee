describe "Jasmine Teaspoon.Spec", ->

  beforeEach ->
    @mockSuite =
      getFullName: -> "_full jasmine name_"
    @mockSpecResultsItems = [
      {message: "_jasmine_message1_", trace: {stack: "_jasmine_stack_trace1_"}, passed: -> false}
      {message: "_jasmine_message2_", trace: {stack: "_jasmine_stack_trace2_"}, passed: -> false}
    ]
    @mockSpecResults =
      skipped: false
      passed: -> true
      getItems: => @mockSpecResultsItems
    @mockSpec =
      description: "_jasmine_description_"
      viewId: 42
      pending: false
      suite: @mockSuite
      getFullName: -> "_full jasmine description_"
      results: => @mockSpecResults

  describe "constructor", ->

    it "has the expected properties", ->
      spec = new Teaspoon.Spec(@mockSpec)
      expect(spec.fullDescription).toBe("_full jasmine description_")
      expect(spec.description).toBe("_jasmine_description_")
      expect(spec.link).toBe("?grep=_full%20jasmine%20description_")
      expect(spec.parent).toBe(@mockSuite)
      expect(spec.suiteName).toBe("_full jasmine name_")
      expect(spec.viewId).toBe(42)
      expect(spec.pending).toBe(false)


  describe "#errors", ->

    it "returns the expected object", ->
      spec = new Teaspoon.Spec(@mockSpec)
      expect(spec.errors()).toEqual([{message: "_jasmine_message1_", stack: "_jasmine_stack_trace1_"}, {message: "_jasmine_message2_", stack: "_jasmine_stack_trace2_"}])
      spyOn(@mockSpecResultsItems[0], "passed").andReturn(true)
      spec = new Teaspoon.Spec(@mockSpec)
      expect(spec.errors()).toEqual([{message: "_jasmine_message2_", stack: "_jasmine_stack_trace2_"}])


  describe "#getParents", ->

    it "gets the parent suites", ->
      spec = new Teaspoon.Spec(@mockSpec)
      expect(spec.getParents()[0].fullDescription).toEqual("_full jasmine name_")


  describe "#result", ->

    describe "passing", ->

      it "returns the expected object", ->
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.result()).toEqual({status: "passed", skipped: false})

    describe "skipped", ->

      it "returns the expected object", ->
        @mockSpecResults.skipped = true
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.result()).toEqual({status: "passed", skipped: true})

    describe "pending", ->

      it "returns the expected object", ->
        @mockSpec.pending = true
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.result()).toEqual({status: "pending", skipped: false})

    describe "failing", ->

      it "returns the expected object", ->
        spyOn(@mockSpecResults, "passed").andReturn(false)
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.result()).toEqual({status: "failed", skipped: false})



describe "Jasmine Teaspoon.Suite", ->

  beforeEach ->
    @mockParentSuite = {}
    @mockSuite =
      description: "_jasmine_description_"
      parentSuite: @mockParentSuite
      viewId: 42
      getFullName: -> "_full jasmine description_"

  describe "constructor", ->

    it "has the expected properties", ->
      suite = new Teaspoon.Suite(@mockSuite)
      expect(suite.fullDescription).toBe("_full jasmine description_")
      expect(suite.description).toBe("_jasmine_description_")
      expect(suite.link).toBe("?grep=_full%20jasmine%20description_")
      expect(suite.parent).toBe(@mockParentSuite)
      expect(suite.viewId).toBe(42)
