describe "Teaspoon", ->

  describe "class level API", ->

    it "has the expected API", ->
      return unless Object.keys # can't test in ie
      keys = Object.keys(Teaspoon)
      # common
      expect(keys).toContain("defer")
      expect(keys).toContain("slow")
      expect(keys).toContain("root")
      expect(keys).toContain("finished")
      expect(keys).toContain("execute")
      expect(keys).toContain("version")
      # caching
      expect(keys).toContain("Date")
      expect(keys).toContain("location")


  describe ".execute", ->

    beforeEach ->
      Teaspoon.defer = false
      spyOn(Teaspoon, 'reload')
      @spy = spyOn(Teaspoon, "Runner")

    it "allows deferring (thus not instantiating the runner)", ->
      Teaspoon.defer = true
      Teaspoon.execute()
      expect(@spy).wasNotCalled()

    it "will execute if it should", ->
      Teaspoon.execute()
      expect(@spy).toHaveBeenCalled()


  describe ".hook", ->

    beforeEach ->
      @xhr = jasmine.createSpyObj("xhr", ["open", "setRequestHeader", "send"])
      spyOn(window, "XMLHttpRequest").andReturn(@xhr)

    it "makes the proper ajax request", ->
      Teaspoon.hook("foo", {bar: "baz"})
      expect(@xhr.open).toHaveBeenCalledWith("POST", "/teaspoon/default/foo", false)
      expect(@xhr.setRequestHeader).toHaveBeenCalledWith("Content-Type", "application/json")
      expect(@xhr.send).toHaveBeenCalledWith('{"args":{"bar":"baz"}}')
