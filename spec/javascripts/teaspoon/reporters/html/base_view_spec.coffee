describe "Teaspoon.Reporters.BaseView", ->

  beforeEach ->
    @base = new Teaspoon.Reporters.BaseView()

  describe "constructor", ->

    it "calls build", ->
      spy = spyOn(Teaspoon.Reporters.BaseView.prototype, "build")
      new Teaspoon.Reporters.BaseView()
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
      el = {innerHTML: "bar"}
      spy = spyOn(@base, "findEl").andReturn(el)
      @base.setText("foo-id", "foo")
      expect(spy).toHaveBeenCalledWith("foo-id")
      expect(el.innerHTML).toBe("foo")


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
