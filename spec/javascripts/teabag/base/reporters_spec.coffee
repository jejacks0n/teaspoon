describe "Teabag.Reporters.NormalizedSpec", ->

  beforeEach ->
    @jasmineSuite = {}
    @jasmineSpecResultsItems = [
      {message: "_jasmine_message1_", trace: {stack: "_jasmine_stack_trace1_"}, passed: -> false},
      {message: "_jasmine_message2_", trace: {stack: "_jasmine_stack_trace2_"}, passed: -> false},
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
    @mochaSuite = {}
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
        spec = new Teabag.Reporters.NormalizedSpec(@jasmineSpec)
        expect(spec.fullDescription).toEqual("_full jasmine description_")
        expect(spec.description).toEqual("_jasmine_description_")
        expect(spec.link).toEqual("?grep=_full%20jasmine%20description_")
        expect(spec.parent).toBe(@jasmineSuite)
        expect(spec.viewId).toBe(42)
        expect(spec.pending).toBe(false)

    describe "with mocha type spec", ->

      it "has the expected properties", ->
        spec = new Teabag.Reporters.NormalizedSpec(@mochaSpec)
        expect(spec.fullDescription).toEqual("_full mocha description_")
        expect(spec.description).toEqual("_mocha_description_")
        expect(spec.link).toEqual("?grep=_full%20mocha%20description_")
        expect(spec.parent).toBe(@mochaSuite)
        expect(spec.viewId).toBe(420)
        expect(spec.pending).toBe(false)


  describe "#errors", ->

    describe "with jasmine type spec", ->

      it "returns the expected object", ->
        spec = new Teabag.Reporters.NormalizedSpec(@jasmineSpec)
        expect(spec.errors()).toEqual([{message: "_jasmine_message1_", stack: "_jasmine_stack_trace1_"}, {message: "_jasmine_message2_", stack: "_jasmine_stack_trace2_"}])
        spyOn(@jasmineSpecResultsItems[0], 'passed').andReturn(true)
        spec = new Teabag.Reporters.NormalizedSpec(@jasmineSpec)
        expect(spec.errors()).toEqual([{message: "_jasmine_message2_", stack: "_jasmine_stack_trace2_"}])

    describe "with mocha type spec", ->

      it "returns the expected object", ->
        spec = new Teabag.Reporters.NormalizedSpec(@mochaSpec)
        expect(spec.errors()).toEqual([{message: "_mocha_message_", stack: "_mocha_stack_trace_"}])


  describe "#results", ->

    describe "with jasmine type spec", ->

      describe "passing", ->

        it "returns the expected object", ->
          spec = new Teabag.Reporters.NormalizedSpec(@jasmineSpec)
          expect(spec.result()).toEqual({status: "passed", skipped: false})

      describe "skipped", ->

        it "returns the expected object", ->
          @jasmineSpecResults.skipped = true
          spec = new Teabag.Reporters.NormalizedSpec(@jasmineSpec)
          expect(spec.result()).toEqual({status: "passed", skipped: true})

      describe "pending", ->

        it "returns the expected object", ->
          @jasmineSpec.pending = true
          spec = new Teabag.Reporters.NormalizedSpec(@jasmineSpec)
          expect(spec.result()).toEqual({status: "pending", skipped: false})

      describe "failing", ->

        it "returns the expected object", ->
          spyOn(@jasmineSpecResults, 'passed').andReturn(false)
          spec = new Teabag.Reporters.NormalizedSpec(@jasmineSpec)
          expect(spec.result()).toEqual({status: "failed", skipped: false})


    describe "with mocha type spec", ->

      describe "passing", ->

        it "returns the expected object", ->
          spec = new Teabag.Reporters.NormalizedSpec(@mochaSpec)
          expect(spec.result()).toEqual({status: "passed", skipped: false})

      describe "skipped", ->

        it "returns the expected object", ->
          @mochaSpec.state = "skipped"
          spec = new Teabag.Reporters.NormalizedSpec(@mochaSpec)
          expect(spec.result()).toEqual({status: "passed", skipped: true})

      describe "pending", ->

        it "returns the expected object", ->
          @mochaSpec.pending = true
          spec = new Teabag.Reporters.NormalizedSpec(@mochaSpec)
          expect(spec.result()).toEqual({status: "pending", skipped: false})

      describe "failing", ->

        it "returns the expected object", ->
          @mochaSpec.state = "failed"
          spec = new Teabag.Reporters.NormalizedSpec(@mochaSpec)
          expect(spec.result()).toEqual({status: "failed", skipped: false})



describe "Teabag.Reporters.NormalizedSuite", ->

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
        suite = new Teabag.Reporters.NormalizedSuite(@jasmineSuite)
        expect(suite.fullDescription).toEqual("_full jasmine description_")
        expect(suite.description).toEqual("_jasmine_description_")
        expect(suite.link).toEqual("?grep=_full%20jasmine%20description_")
        expect(suite.parent).toBe(@jasmineParentSuite)
        expect(suite.viewId).toBe(42)

    describe "with mocha type suite", ->

      it "has the expected properties", ->
        suite = new Teabag.Reporters.NormalizedSuite(@mochaSuite)
        expect(suite.fullDescription).toEqual("_full mocha description_")
        expect(suite.description).toEqual("_mocha_description_")
        expect(suite.link).toEqual("?grep=_full%20mocha%20description_")
        expect(suite.parent).toBe(@mochaParentSuite)
        expect(suite.viewId).toBe(420)



describe "Teabag.Reporters.BaseView", ->

  beforeEach ->
    @base = new Teabag.Reporters.BaseView()

  describe "constructor", ->

    it "calls build", ->
      spy = spyOn(Teabag.Reporters.BaseView.prototype, "build")
      new Teabag.Reporters.BaseView()
      expect(spy).toHaveBeenCalled()


  describe "#build", ->

    it "builds an element", ->
      @base.build("foo")
      expect(@base.el.className).toBe("foo")


  describe "#appendTo", ->

    it "calls appendChild on the passed element", ->
      el = {appendChild: ->}
      spy = spyOn(el, "appendChild")
      @base.appendTo(el)
      expect(spy).toHaveBeenCalledWith(@base.el)


  describe "#append", ->

    it "calls appendChild on our element", ->
      @base.el = {appendChild: ->}
      spy = spyOn(@base.el, "appendChild")
      otherEl = {}
      @base.append(otherEl)
      expect(spy).toHaveBeenCalledWith(otherEl)


  describe "#createEl", ->

    it "creates an element with a className", ->
      el = @base.createEl("em", "foo")
      expect(el.tagName).toBe("EM")
      expect(el.className).toBe("foo")


  describe "#findEl", ->

    it "finds an element and momoizes it", ->
      @base.findEl("controls")
      expect(@base.elements["controls"]).toBeDefined()


  describe "#setText", ->

    it "finds an el and sets it's innerText", ->
      el = {innerText: "bar"}
      spy = spyOn(@base, "findEl").andReturn(el)
      @base.setText("foo-id", "foo")
      expect(spy).toHaveBeenCalledWith("foo-id")
      expect(el.innerText).toBe("foo")


  describe "#setHtml", ->

    it "finds an el and sets it's innerHTML", ->
      el = {innerHTML: "bar"}
      spy = spyOn(@base, "findEl").andReturn(el)
      @base.setHtml("foo-id", "foo")
      expect(spy).toHaveBeenCalledWith("foo-id")
      expect(el.innerHTML).toBe("foo")


  describe "#setClass", ->

    it "finds an el and sets a class on it", ->
      el = {className: "bar"}
      spy = spyOn(@base, "findEl").andReturn(el)
      @base.setClass("foo-id", "foo")
      expect(spy).toHaveBeenCalledWith("foo-id")
      expect(el.className).toBe("foo")


  describe "#htmlSafe", ->

    it "makes a string html safe", ->
      expect(@base.htmlSafe("<div></div>")).toEqual("&lt;div&gt;&lt;/div&gt;")
