class Teabag.View

  constructor: ->
    @build()


  build: (className) ->
    @el = @createEl("li", className)


  appendTo: (el) ->
    el.appendChild(@el)


  append: (el) ->
    @el.appendChild(el)


  createEl: (type, className = "") ->
    el = document.createElement(type)
    el.className = className
    el


  findEl: (id) ->
    @elements ||= []
    @elements[id] ||= document.getElementById("teabag-#{id}")


  setText: (id, value) ->
    el = @findEl(id)
    el.innerText = value


  setHtml: (id, value, add = false) ->
    el = @findEl(id)
    if add then el.innerHTML += value else el.innerHTML = value


  setClass: (id, value) ->
    el = @findEl(id)
    el.className = value



class Teabag.ConsoleReporterBase

  constructor: ->
    @fails = []
    @total = 0
    @start = Date.now()


  reportSpecResults: (spec) ->
    if spec.results().passed()
      status = "pass"
    else if spec.results.skipped
      status = "skipped"
    else
      @trackFailure(spec)
      status = "fail"
    @total += 1
    @log(type: "spec", status: status, description: spec.description, suite: spec.suite.getFullName())


  reportRunnerResults: ->
    @log(type: "results", total: @total, failures: @fails, elapsed: ((Date.now() - @start) / 1000).toFixed(5))
    Teabag.finished = true


  trackFailure: (spec) ->
    for item in spec.results().getItems()
      @fails.push(spec: spec.getFullName(), description: item.toString(), link: "?grep=#{encodeURIComponent(spec.getFullName())}", trace: item.trace.stack || item.trace.toString())


  log: (obj = {}) ->
    obj["_teabag"] = true
    console.log(JSON.stringify(obj))



class Teabag.HtmlReporterBase extends Teabag.View

  constructor: ->
    super
