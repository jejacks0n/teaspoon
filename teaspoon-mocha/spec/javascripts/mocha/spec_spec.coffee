describe "Teaspoon.Mocha.Spec", ->

  beforeEach ->
    @mockSuite =
      fullTitle: -> "_full mocha name_"
      parent:
        root: true
    @mockSpec =
      title: "_mocha_description_"
      parent: @mockSuite
      viewId: 420
      pending: false
      state: "passed"
      err: {message: "_mocha_message_", stack: "_mocha_stack_trace_"}
      fullTitle: -> "_full mocha description_"

  describe "constructor", ->

    it "has the expected properties", ->
      originalParams = Teaspoon.params
      Teaspoon.params.file = "spec.js"

      spec = new Teaspoon.Mocha.Spec(@mockSpec)
      expect(spec.fullDescription).to.be("_full mocha description_")
      expect(spec.description).to.be("_mocha_description_")
      expect(spec.link).to.be("?grep=_full%20mocha%20description_&file=spec.js")
      expect(spec.parent).to.be(@mockSuite)
      expect(spec.suiteName).to.be("_full mocha name_")
      expect(spec.viewId).to.be(420)
      expect(spec.pending).to.be(false)

      Teaspoon.params = originalParams


  describe "#errors", ->

    it "returns the expected object", ->
      spec = new Teaspoon.Mocha.Spec(@mockSpec)
      expect(spec.errors()).to.eql([{message: "_mocha_message_", stack: "_mocha_stack_trace_"}])


  describe "#getParents", ->

    it "gets the parent suites", ->
      spec = new Teaspoon.Mocha.Spec(@mockSpec)
      expect(spec.getParents()[0].fullDescription).to.be("_full mocha name_")


  describe "#result", ->

    describe "passing", ->

      it "returns the expected object", ->
        spec = new Teaspoon.Mocha.Spec(@mockSpec)
        expect(spec.result()).to.eql({status: "passed", skipped: false})

    describe "skipped", ->

      it "returns the expected object", ->
        @mockSpec.state = "skipped"
        spec = new Teaspoon.Mocha.Spec(@mockSpec)
        expect(spec.result()).to.eql({status: "passed", skipped: true})

    describe "pending", ->

      it "returns the expected object", ->
        @mockSpec.pending = true
        spec = new Teaspoon.Mocha.Spec(@mockSpec)
        expect(spec.result()).to.eql({status: "pending", skipped: true})

    describe "failing", ->

      it "returns the expected object", ->
        @mockSpec.state = "failed"
        spec = new Teaspoon.Mocha.Spec(@mockSpec)
        expect(spec.result()).to.eql({status: "failed", skipped: false})
