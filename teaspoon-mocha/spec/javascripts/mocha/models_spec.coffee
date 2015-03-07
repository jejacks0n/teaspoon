describe "Mocha Teaspoon.Spec", ->

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
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.fullDescription).to.be("_full mocha description_")
        expect(spec.description).to.be("_mocha_description_")
        expect(spec.link).to.be("?grep=_full%20mocha%20description_")
        expect(spec.parent).to.be(@mockSuite)
        expect(spec.suiteName).to.be("_full mocha name_")
        expect(spec.viewId).to.be(420)
        expect(spec.pending).to.be(false)


  describe "#errors", ->

    it "returns the expected object", ->
      spec = new Teaspoon.Spec(@mockSpec)
      expect(spec.errors()).to.eql([{message: "_mocha_message_", stack: "_mocha_stack_trace_"}])


  describe "#getParents", ->

    it "gets the parent suites", ->
      spec = new Teaspoon.Spec(@mockSpec)
      expect(spec.getParents()[0].fullDescription).to.be("_full mocha name_")


  describe "#result", ->

    describe "passing", ->

      it "returns the expected object", ->
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.result()).to.eql({status: "passed", skipped: false})

    describe "skipped", ->

      it "returns the expected object", ->
        @mockSpec.state = "skipped"
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.result()).to.eql({status: "passed", skipped: true})

    describe "pending", ->

      it "returns the expected object", ->
        @mockSpec.pending = true
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.result()).to.eql({status: "pending", skipped: false})

    describe "failing", ->

      it "returns the expected object", ->
        @mockSpec.state = "failed"
        spec = new Teaspoon.Spec(@mockSpec)
        expect(spec.result()).to.eql({status: "failed", skipped: false})



describe "Mocha Teaspoon.Suite", ->

  beforeEach ->
    @mockParentSuite = {root: false}
    @mockSuite =
      fullTitle: -> "_full mocha description_"
      title: "_mocha_description_"
      viewId: 420
      parent: @mockParentSuite

  describe "constructor", ->

    it "has the expected properties", ->
      suite = new Teaspoon.Suite(@mockSuite)
      expect(suite.fullDescription).to.be("_full mocha description_")
      expect(suite.description).to.be("_mocha_description_")
      expect(suite.link).to.be("?grep=_full%20mocha%20description_")
      expect(suite.parent).to.be(@mockParentSuite)
      expect(suite.viewId).to.be(420)
