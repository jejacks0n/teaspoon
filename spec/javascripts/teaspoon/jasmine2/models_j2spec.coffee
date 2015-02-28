describe "Jasmine 2 Teaspoon.Spec", ->

  beforeEach ->
    @mockSuite =
      fullName: "_full jasmine name_"
    @mockFailedSpecs = [
      {message: "_jasmine_message1_", stack: "_jasmine_stack_trace1_"}
      {message: "_jasmine_message2_", stack: "_jasmine_stack_trace2_"}
    ]
    @mockPassedSpecs = []
    @mockSpec =
      id: "42"
      fullName: "_full jasmine description_"
      description: "_jasmine_description_"
      failedExpectations: @mockFailedSpecs
      passedExpectations: @mockPassedSpecs
      pendingReason: ""
      parent: @mockSuite
      status: "passed"

  describe "constructor", ->

    it "has the expected properties", ->
      spec = new Teaspoon.Spec(@mockSpec, @mockSuite)
      expect(spec.fullDescription).toBe("_full jasmine description_")
      expect(spec.description).toBe("_jasmine_description_")
      expect(spec.link).toBe("?grep=_full%20jasmine%20description_")
      expect(spec.parent).toBe(@mockSuite)
      expect(spec.suiteName).toBe("_full jasmine name_")
      expect(spec.viewId).toBe("42")
      expect(spec.pending).toBe(false)


  describe "#errors", ->

    it "returns the expected object", ->
      spec = new Teaspoon.Spec(@mockSpec, @mockSuite)
      expect(spec.errors()).toEqual([{message: "_jasmine_message1_", stack: "_jasmine_stack_trace1_"}, {message: "_jasmine_message2_", stack: "_jasmine_stack_trace2_"}])
      @mockPassedSpecs.push(@mockFailedSpecs.splice(0, 1)[0])
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
        @mockSpec.status = "disabled"
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.result()).toEqual({status: "passed", skipped: true})

    describe "pending", ->

      it "returns the expected object", ->
        @mockSpec.status = "pending"
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.result()).toEqual({status: "pending", skipped: false})

    describe "failing", ->

      it "returns the expected object", ->
        @mockSpec.status = "failed"
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.result()).toEqual({status: "failed", skipped: false})



describe "Jasmine 2 Teaspoon.Suite", ->

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
