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
      spyOn(Teaspoon, "reload")
      @spy = spyOn(Teaspoon.framework, "Runner")

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


  describe ".resolveClass", ->

    it "finds a class, preferring the framework namespace, falling back on Teaspoon", ->
      Teaspoon.Some = {}
      Teaspoon.Some.Namespace = {}

      expect(Teaspoon.resolveClass("Some.Namespace")).toEqual(Teaspoon.Some.Namespace)

      Teaspoon.framework.Some = {}
      Teaspoon.framework.Some.Namespace = {}

      expect(Teaspoon.resolveClass("Some.Namespace")).toEqual(Teaspoon.framework.Some.Namespace)

    it "throws an error if it can't find the requested class", ->
      expect(-> Teaspoon.resolveClass("Nope")).toThrow("Could not find the class you're looking for: Nope")


  describe ".log", ->

    it "does not error if console.log does not exist", ->
      originalLog = window.console.log
      window.console.log = undefined

      expect(-> Teaspoon.log('__spec_results__')).not.toThrow();

      window.console.log = originalLog

    it "does not error if console does not exist", ->
      originalConsole = window.console
      window.console = undefined

      expect(-> Teaspoon.log('__spec_results__')).not.toThrow();

      window.console = originalConsole
