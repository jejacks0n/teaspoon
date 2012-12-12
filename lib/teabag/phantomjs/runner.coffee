system  = require "system"
webpage = require "webpage"

class @Runner

  constructor: ->
    @url = system.args[1]
    @timeout = parseInt(system.args[2] || 180) * 1000


  run: ->
    @initPage()
    @loadPage()


  initPage: ->
    @page = webpage.create()


  loadPage: ->
    @page.open(@url)
    @page[name] = method for name, method of @pageCallbacks()


  waitForResults: =>
    @fail("Timed out") if (Date.now() - @start) >= @timeout
    finished = @page.evaluate(-> window.Teabag && window.Teabag.finished)
    if finished then @finish() else setTimeout(@waitForResults, 200)


  fail: (msg = null, errno = 1) ->
    console.log("Error: #{msg}") if msg
    console.log(JSON.stringify(_teabag: true, type: "exception"))
    phantom.exit(errno)


  finish: ->
    console.log(" ")
    phantom.exit(0)


  pageCallbacks: ->
    onError: (msg, trace) ->
      console.log(JSON.stringify({_teabag: true, type: "error", msg: msg, trace: trace}))


    onConsoleMessage: (msg) =>
      console.log(msg)


    onLoadFinished: (status) =>
      @start = Date.now()
      defined = @page.evaluate(-> window.Teabag)
      unless status == "success" && defined
        @fail("Failed to load: #{@url}")
        return

      @waitForResults()


new Runner().run()
