describe "Teaspoon.Reporters.HTML.FailureView", ->

  describe "constructor", ->

    it "assigns @spec", ->
      spec = {foo: "bar"}
      spyOn(Teaspoon.Reporters.HTML.FailureView.prototype, 'build')
      subject = new Teaspoon.Reporters.HTML.FailureView(spec)
      expect(subject.spec).toBe(spec)


  describe "#build", ->

    beforeEach ->
      @mockSpec =
        link: "_link_",
        fullDescription: "_full_description_"
        errors: ->
          [{message: "_error_message_", stack: "_error_stack_"}]
      @subject = new Teaspoon.Reporters.HTML.FailureView(@mockSpec)
      @subject.build()

    it "builds the html", ->
      content = @subject.el.innerHTML
      expect(content).toContain('href="_link_"')
      expect(content).toContain('_full_description_')
      expect(content).toContain("<strong>_error_message_</strong>")
      expect(content).toContain("_error_stack_")
