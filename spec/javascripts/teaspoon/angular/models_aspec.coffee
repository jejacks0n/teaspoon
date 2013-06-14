describe "Angular Teaspoon.Spec", ->

  beforeEach ->
    @mockStep =
      name: "_step name_"
      startTime: 1363303012091
      endTime: 1363303012790
      duration: 699
      status: "failure"
      line: "_step line_"
      error: "_step error_"
    @mockSpec =
      id: 1
      fullDefinitionName: "_full angular name_"
      name: "_angular description_"
      startTime: 1363303012081
      endTime: 1363303013128
      duration: 1047
      status: "success"
      steps: [@mockStep]

  describe "#constructor", ->

    it "has the expected properties", ->
      spec = new Teaspoon.Spec(@mockSpec)
      _expect(spec.fullDescription).toBe("_full angular name_: _angular description_")
      _expect(spec.description).toBe("_angular description_")
      _expect(spec.link).toBe("#")
      _expect(spec.suiteName).toBe("_full angular name_")
      _expect(spec.viewId).toBe(1)
      _expect(spec.pending).toBe(false)
      #_expect(spec.parent).toBe(@mockSuite)


  describe "#errors", ->

    it "returns the expected object", ->
      spec = new Teaspoon.Spec(@mockSpec)
      _expect(spec.errors()).toEqual([{message: "_step error_", stack: ["_step line_"]}])


  describe "#getParents", ->

    it "gets the parent suites", ->
      spec = new Teaspoon.Spec(@mockSpec)
      _expect(spec.getParents()[0].fullDescription).toBe("_full angular name_")


  describe "#result", ->

    describe "passing", ->

      it "returns the expected object", ->
        spec = new Teaspoon.Spec(@mockSpec)
        _expect(spec.result()).toEqual({status: "passed", skipped: false})

    #describe "skipped", ->
    #
    #  it "returns the expected object", ->
    #    @mockSpec.status = "skipped"
    #    spec = new Teaspoon.Spec(@mockSpec)
    #    _expect(spec.result()).toEqual({status: "passed", skipped: true})

    #describe "pending", ->
    #
    #  it "returns the expected object", ->
    #    @mockSpec.status = "failure"
    #    spec = new Teaspoon.Spec(@mockSpec)
    #    _expect(spec.result()).toEqual({status: "pending", skipped: false})

    describe "failing", ->

      it "returns the expected object", ->
        @mockSpec.status = "failure"
        spec = new Teaspoon.Spec(@mockSpec)
        _expect(spec.result()).toEqual(status: "failed", skipped: false)


describe "Angular Teaspoon.Suite", ->

  beforeEach ->
    @mockSpec =
      fullDefinitionName: "_full angular name_"
      name: "_angular description_"

  describe "#constructor", ->

    it "has the expected properties", ->
      suite = new Teaspoon.Suite(@mockSpec)
      _expect(suite.fullDescription).toBe("_full angular name_")
      _expect(suite.description).toBe("_full angular name_")
      _expect(suite.link).toBe("#")
      _expect(suite.parent).toEqual(root: true)
      _expect(suite.viewId).toBe(null)

