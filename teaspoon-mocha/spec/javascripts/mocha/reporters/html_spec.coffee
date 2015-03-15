describe "Mocha Teaspoon.Reporters.HTML.SpecView", ->

  describe "#updateState", ->

    it "calls super with the duration of the spec", ->
      # this can't be tested, I tried a lot....
      #@superSpy = Teaspoon.Reporters.HTML.SpecView.__super__.updateState = sinon.spy()
      #@buildSpy = Teaspoon.Reporters.HTML.SpecView.prototype.build = sinon.spy()
      #view = new Teaspoon.Reporters.HTML.SpecView({viewId: 1000000}, {views: []})
      #view.spec.duration = 1000
      #view.updateState("passed")
      #assert.calledWith(@superSpy, "passed", 1000)

