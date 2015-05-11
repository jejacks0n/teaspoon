describe "Teaspoon.Mocha.Suite", ->

  beforeEach ->
    @mockParentSuite = {root: false}
    @mockSuite =
      fullTitle: -> "_full mocha description_"
      title: "_mocha_description_"
      viewId: 420
      parent: @mockParentSuite

  describe "constructor", ->

    it "has the expected properties", ->
      originalParams = Teaspoon.params
      Teaspoon.params.file = "spec.js"

      suite = new Teaspoon.Mocha.Suite(@mockSuite)
      expect(suite.fullDescription).to.be("_full mocha description_")
      expect(suite.description).to.be("_mocha_description_")
      expect(suite.link).to.be("?grep=_full%20mocha%20description_&file=spec.js")
      expect(suite.parent).to.be(@mockParentSuite)
      expect(suite.viewId).to.be(420)

      Teaspoon.params = originalParams
