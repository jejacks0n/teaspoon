system  = require "system"
webpage = require "webpage"

class @Runner

  constructor: ->
    @url = system.args[1]
    @timeout = parseInt(system.args[2] || 180) * 1000 # todo: add configuration -- default timeout is 3 minutes


  run: ->
    @initPage()
    @loadPage()


  initPage: ->
    @page = webpage.create()
    @page.viewportSize = {width: 800, height: 800}


  loadPage: ->
    @page.open(@url)
    @page[name] = method for name, method of @pageCallbacks()


  waitForResults: =>
    @fail("Timed out") if (new Date().getTime() - @start) >= @timeout
    finished = @page.evaluate(-> window.Teaspoon && window.Teaspoon.finished)
    if finished then @finish() else setTimeout(@waitForResults, 200)


  fail: (msg = null, errno = 1) ->
    console.log("Error: #{msg}") if msg
    console.log(JSON.stringify(_teaspoon: true, type: "exception"))
    phantom.exit(errno)


  finish: ->
    console.log(" ")
    phantom.exit(0)


  pageCallbacks: ->
    onError: (message, trace) =>
      console.log(JSON.stringify(_teaspoon: true, type: "error", message: message, trace: trace))
      @errored = true


    onConsoleMessage: (msg) =>
      console.log(msg)
      clearTimeout(@errorTimeout) if @errorTimeout
      if @errored
        @errorTimeout = setTimeout((=> @fail('Javascript error has cause a timeout.')), 1000)
        @errored = false


    onLoadFinished: (status) =>
      return if @start
      @start = new Date().getTime()
      defined = @page.evaluate(-> window.Teaspoon)
      @page.injectJs('./IndexedDBShim.min.js', () =>
        unless status == "success" && defined
          @fail("Failed to load: #{@url}")
          return
      )
      @waitForResults()



new Runner().run()
