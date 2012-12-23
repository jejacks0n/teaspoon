describe "Teabag.Spec", ->

  beforeEach ->
    @jasmineSuite =
      getFullName: -> "_full jasmine name_"
    @jasmineSpecResultsItems = [
      {message: "_jasmine_message1_", trace: {stack: "_jasmine_stack_trace1_"}, passed: -> false}
      {message: "_jasmine_message2_", trace: {stack: "_jasmine_stack_trace2_"}, passed: -> false}
    ]
    @jasmineSpecResults =
      skipped: false
      passed: -> true
      getItems: => @jasmineSpecResultsItems
    @jasmineSpec =
      description: "_jasmine_description_"
      viewId: 42
      pending: false
      suite: @jasmineSuite
      getFullName: -> "_full jasmine description_"
      results: => @jasmineSpecResults
    @mochaSuite =
      fullTitle: -> "_full mocha name_"
    @mochaSpec =
      title: "_mocha_description_"
      parent: @mochaSuite
      viewId: 420
      pending: false
      state: "passed"
      err: {message: "_mocha_message_", stack: "_mocha_stack_trace_"}
      fullTitle: -> "_full mocha description_"

  describe "constructor", ->

    describe "with jasmine type spec", ->

      it "has the expected properties", ->
        spec = new Teabag.Spec(@jasmineSpec)
        expect(spec.fullDescription).toEqual("_full jasmine description_")
        expect(spec.description).toEqual("_jasmine_description_")
        expect(spec.link).toEqual("?grep=_full%20jasmine%20description_")
        expect(spec.parent).toBe(@jasmineSuite)
        expect(spec.suiteName).toBe("_full jasmine name_")
        expect(spec.viewId).toBe(42)
        expect(spec.pending).toBe(false)

    describe "with mocha type spec", ->

      it "has the expected properties", ->
        spec = new Teabag.Spec(@mochaSpec)
        expect(spec.fullDescription).toEqual("_full mocha description_")
        expect(spec.description).toEqual("_mocha_description_")
        expect(spec.link).toEqual("?grep=_full%20mocha%20description_")
        expect(spec.parent).toBe(@mochaSuite)
        expect(spec.suiteName).toBe("_full mocha name_")
        expect(spec.viewId).toBe(420)
        expect(spec.pending).toBe(false)


  describe "#errors", ->

    describe "with jasmine type spec", ->

      it "returns the expected object", ->
        spec = new Teabag.Spec(@jasmineSpec)
        expect(spec.errors()).toEqual([{message: "_jasmine_message1_", stack: "_jasmine_stack_trace1_"}, {message: "_jasmine_message2_", stack: "_jasmine_stack_trace2_"}])
        spyOn(@jasmineSpecResultsItems[0], "passed").andReturn(true)
        spec = new Teabag.Spec(@jasmineSpec)
        expect(spec.errors()).toEqual([{message: "_jasmine_message2_", stack: "_jasmine_stack_trace2_"}])

    describe "with mocha type spec", ->

      it "returns the expected object", ->
        spec = new Teabag.Spec(@mochaSpec)
        expect(spec.errors()).toEqual([{message: "_mocha_message_", stack: "_mocha_stack_trace_"}])


  describe "#getParents", ->

    it "gets the parent suites", ->
      spec = new Teabag.Spec(@jasmineSpec)
      expect(spec.getParents()[0].fullDescription).toEqual("_full jasmine name_")


  describe "#result", ->

    describe "with jasmine type spec", ->

      describe "passing", ->

        it "returns the expected object", ->
          spec = new Teabag.Spec(@jasmineSpec)
          expect(spec.result()).toEqual({status: "passed", skipped: false})

      describe "skipped", ->

        it "returns the expected object", ->
          @jasmineSpecResults.skipped = true
          spec = new Teabag.Spec(@jasmineSpec)
          expect(spec.result()).toEqual({status: "passed", skipped: true})

      describe "pending", ->

        it "returns the expected object", ->
          @jasmineSpec.pending = true
          spec = new Teabag.Spec(@jasmineSpec)
          expect(spec.result()).toEqual({status: "pending", skipped: false})

      describe "failing", ->

        it "returns the expected object", ->
          spyOn(@jasmineSpecResults, "passed").andReturn(false)
          spec = new Teabag.Spec(@jasmineSpec)
          expect(spec.result()).toEqual({status: "failed", skipped: false})


    describe "with mocha type spec", ->

      describe "passing", ->

        it "returns the expected object", ->
          spec = new Teabag.Spec(@mochaSpec)
          expect(spec.result()).toEqual({status: "passed", skipped: false})

      describe "skipped", ->

        it "returns the expected object", ->
          @mochaSpec.state = "skipped"
          spec = new Teabag.Spec(@mochaSpec)
          expect(spec.result()).toEqual({status: "passed", skipped: true})

      describe "pending", ->

        it "returns the expected object", ->
          @mochaSpec.pending = true
          spec = new Teabag.Spec(@mochaSpec)
          expect(spec.result()).toEqual({status: "pending", skipped: false})

      describe "failing", ->

        it "returns the expected object", ->
          @mochaSpec.state = "failed"
          spec = new Teabag.Spec(@mochaSpec)
          expect(spec.result()).toEqual({status: "failed", skipped: false})



describe "Teabag.Suite", ->

  beforeEach ->
    @jasmineParentSuite = {}
    @jasmineSuite =
      description: "_jasmine_description_"
      parentSuite: @jasmineParentSuite
      viewId: 42
      getFullName: -> "_full jasmine description_"
    @mochaParentSuite = {root: false}
    @mochaSuite =
      fullTitle: -> "_full mocha description_"
      title: "_mocha_description_"
      viewId: 420
      parent: @mochaParentSuite

  describe "constructor", ->

    describe "with jasmine type suite", ->

      it "has the expected properties", ->
        suite = new Teabag.Suite(@jasmineSuite)
        expect(suite.fullDescription).toEqual("_full jasmine description_")
        expect(suite.description).toEqual("_jasmine_description_")
        expect(suite.link).toEqual("?grep=_full%20jasmine%20description_")
        expect(suite.parent).toBe(@jasmineParentSuite)
        expect(suite.viewId).toBe(42)

    describe "with mocha type suite", ->

      it "has the expected properties", ->
        suite = new Teabag.Suite(@mochaSuite)
        expect(suite.fullDescription).toEqual("_full mocha description_")
        expect(suite.description).toEqual("_mocha_description_")
        expect(suite.link).toEqual("?grep=_full%20mocha%20description_")
        expect(suite.parent).toBe(@mochaParentSuite)
        expect(suite.viewId).toBe(420)
