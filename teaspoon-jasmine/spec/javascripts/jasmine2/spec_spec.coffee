describe "Teaspoon.Jasmine2.Spec", ->

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
      originalParams = Teaspoon.params
      Teaspoon.params.file = "spec.js"

      spec = new Teaspoon.Jasmine2.Spec(@mockSpec)
      expect(spec.fullDescription).toBe("_full jasmine description_")
      expect(spec.description).toBe("_jasmine_description_")
      expect(spec.link).toBe("?grep=_full%20jasmine%20description_&file=spec.js")
      expect(spec.parent).toBe(@mockSuite)
      expect(spec.suiteName).toBe("_full jasmine name_")
      expect(spec.viewId).toBe("42")
      expect(spec.pending).toBe(false)

      Teaspoon.params = originalParams

    it "it does not set suite details if a spec is being focused (fit) because it doesn't contain a suite", ->
      @mockSpec.parent = undefined

      spec = new Teaspoon.Jasmine2.Spec(@mockSpec)
      expect(spec.parent).toBe(undefined)
      expect(spec.suiteName).toBe(undefined)


  describe "#errors", ->

    it "returns the expected object", ->
      spec = new Teaspoon.Jasmine2.Spec(@mockSpec)
      expect(spec.errors()).toEqual([{message: "_jasmine_message1_", stack: "_jasmine_stack_trace1_"}, {message: "_jasmine_message2_", stack: "_jasmine_stack_trace2_"}])
      @mockPassedSpecs.push(@mockFailedSpecs.splice(0, 1)[0])
      spec = new Teaspoon.Jasmine2.Spec(@mockSpec)
      expect(spec.errors()).toEqual([{message: "_jasmine_message2_", stack: "_jasmine_stack_trace2_"}])


  describe "#getParents", ->

    it "gets the parent suites", ->
      spec = new Teaspoon.Jasmine2.Spec(@mockSpec)
      expect(spec.getParents()[0].fullDescription).toEqual("_full jasmine name_")


  describe "#result", ->

    describe "passing", ->

      it "returns the expected object", ->
        spec = new Teaspoon.Jasmine2.Spec(@mockSpec)
        expect(spec.result()).toEqual({status: "passed", skipped: false})

    describe "skipped", ->

      it "returns the expected object", ->
        @mockSpec.status = "disabled"
        spec = new Teaspoon.Jasmine2.Spec(@mockSpec)
        expect(spec.result()).toEqual({status: "passed", skipped: true})

    describe "pending", ->

      it "returns the expected object", ->
        @mockSpec.status = "pending"
        spec = new Teaspoon.Jasmine2.Spec(@mockSpec)
        expect(spec.result()).toEqual({status: "pending", skipped: true})

    describe "failing", ->

      it "returns the expected object", ->
        @mockSpec.status = "failed"
        spec = new Teaspoon.Jasmine2.Spec(@mockSpec)
        expect(spec.result()).toEqual({status: "failed", skipped: false})
