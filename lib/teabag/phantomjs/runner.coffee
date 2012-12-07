system  = require "system"
webpage = require "webpage"

class Runner

  constructor: ->
    @url = system.args[1]
    @startTime = Date.now()


  run: ->
    @initPage()
    @loadPage()


  initPage: ->
    @page = webpage.create()


  loadPage: ->
    @page.open(@url)
    @page[name] = method for name, method of @pageCallbacks()


  waitForResults: =>
    finished = @page.evaluate(-> window.Teabag && window.Teabag.finished)
    if finished then @finish() else setTimeout(@waitForResults, 100)


  fail: (msg = null, errno = 1) ->
    console.log(msg) if msg
    phantom.exit(errno)


  finish: ->
    console.log(" ")
    phantom.exit(0)


  pageCallbacks: ->
    onError: (msg, trace) ->
      console.log(JSON.stringify({_teabag: true, type: "error", msg: msg, trace: trace}))


    onConsoleMessage: (msg) =>
      console.log(msg)


    onInitialized: ->
      #console.log('onInitialized')


    onLoadFinished: (status) =>
      @fail("Failed to load: #{@url}") unless status == "success"
      @waitForResults()


new Runner().run()
