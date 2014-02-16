#= require_self
#= require drivers/phantomjs/runner

# stub out phantomjs
window.phantom = {exit: ->}
window.require = (file) ->
  switch file
    when "system" then {args: ["runner.js", "http://host:port/path", "200"]}
    when "webpage" then create: -> {
      open: -> {}
      evaluate: -> {}
    }

describe "PhantomJS Runner", ->

  beforeEach ->
    @logSpy = spyOn(window.console, "log")
    @runner = new Runner()

  describe "constructor", ->

    it "sets the url from system.args", ->
      expect(@runner.url).toBe("http://host:port/path")

    it "sets the timeout from system.args", ->
      expect(@runner.timeout).toBe(200 * 1000)


  describe "#run", ->

    beforeEach ->
      @initSpy = spyOn(@runner, "initPage")
      @loadSpy = spyOn(@runner, "loadPage")

    it "calls initPage", ->
      @runner.run()
      expect(@initSpy).toHaveBeenCalled()

    it "calls loadPage", ->
      @runner.run()
      expect(@loadSpy).toHaveBeenCalled()


  describe "#initPage", ->

    it "creates a webpage and assigns it to @page", ->
      @runner.initPage()
      expect(typeof(@runner.page["open"])).toBe("function")


  describe "#loadPage", ->

    beforeEach ->
      @runner.initPage()

    it "opens the url in the page", ->
      spy = spyOn(@runner.page, "open")
      @runner.loadPage()
      expect(spy).toHaveBeenCalledWith(@runner.url)

    it "attaches all the methods to page", ->
      spyOn(@runner, "pageCallbacks").andCallFake -> {callback1: "method1", callback2: "method2"}
      @runner.loadPage()
      expect(@runner.page.callback1).toBe("method1")
      expect(@runner.page.callback2).toBe("method2")


  describe "#waitForResults", ->

    beforeEach ->
      @timeoutSpy = spyOn(window, "setTimeout")
      @runner.initPage()

    it "evaluates in the context of the page", ->
      spy = spyOn(@runner.page, "evaluate").andReturn(false)
      @runner.waitForResults()
      expect(spy).toHaveBeenCalled()

    it "sets a timeout of 100ms if not finished", ->
      spyOn(@runner.page, "evaluate").andReturn(false)
      @runner.waitForResults()
      expect(@timeoutSpy).toHaveBeenCalled()

    it "calls finish if Teaspoon says that it's finished", ->
      spyOn(@runner.page, "evaluate").andCallFake (f) -> f()
      spy = spyOn(@runner, "finish")
      window.Teaspoon.finished = true
      @runner.waitForResults()
      expect(spy).toHaveBeenCalled()


  describe "#fail", ->

    it "logs the error message", ->
      @runner.fail("_message_")
      expect(@logSpy).toHaveBeenCalledWith('{"_teaspoon":true,"type":"exception","message":"_message_"}')

    it "exits with the error code", ->
      spy = spyOn(phantom, "exit")
      @runner.fail("_message_", 2)
      expect(spy).toHaveBeenCalledWith(2)


  describe "#finish", ->

    it "calls exit with a success code", ->
      spy = spyOn(phantom, "exit")
      @runner.finish()
      expect(spy).toHaveBeenCalledWith(0)


  describe "#pageCallbacks", ->

    it "returns an object with the expected methods", ->
      return unless Object.keys
      object = @runner.pageCallbacks()
      expect(Object.keys(object)).toEqual(["onError", "onConsoleMessage", "onLoadFinished"])


  describe "callback method", ->

    beforeEach ->
      @callbacks = @runner.pageCallbacks()

    describe "#onError", ->

      it "logs the json of a message and trace", ->
        @callbacks.onError("_message_", ["trace1", "trace2"])
        expect(@logSpy).toHaveBeenCalledWith('{"_teaspoon":true,"type":"error","message":"_message_","trace":["trace1","trace2"]}')

      it "calls #fail if the error is a TeaspoonError", ->
        spyOn(@runner, "fail")
        @callbacks.onError("TeaspoonError: _message_")
        expect(@runner.fail).toHaveBeenCalledWith("Execution halted.")

    describe "#onConsoleMessage", ->

      it "logs the message", ->
        @callbacks.onConsoleMessage("_message_")
        expect(@logSpy).toHaveBeenCalledWith("_message_")


    describe "#onLoadFinish", ->

      beforeEach ->
        @runner.initPage()
        @waitSpy = spyOn(@runner, "waitForResults")

      it "fails if the status was not success", ->
        spy = spyOn(@runner, "fail")
        evalSpy = spyOn(@runner.page, "evaluate").andReturn(true)
        @callbacks.onLoadFinished("failure")
        expect(spy).toHaveBeenCalledWith("Failed to load: #{@runner.url}")
        expect(evalSpy).toHaveBeenCalled()
        expect(@waitSpy).wasNotCalled()


      it "calls waitForResults", ->
        @callbacks.onLoadFinished("success")
        expect(@waitSpy).toHaveBeenCalled()

