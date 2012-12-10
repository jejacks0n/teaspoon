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



class Teabag.Reporters.Console

  constructor: ->
    @fails = []
    @total = 0
    @start = Date.now()


  reportSpecResults: (spec) ->
    result = @resultForSpec(spec)
    if result.passed
      status = "pass"
    else if result.skipped
      status = "skipped"
    else
      @trackFailure(spec)
      status = "fail"
    @total += 1
    @log(type: "spec", status: status, description: result.description)


  reportRunnerResults: =>
    @log(type: "results", total: @total, failures: @fails, elapsed: ((Date.now() - @start) / 1000).toFixed(5))
    Teabag.finished = true


  resultForSpec: (spec) ->
    results = spec.results()
    skipped: results.skipped
    passed: results.passed()
    description: spec.description


  trackFailure: (spec) ->
    for item in spec.results().getItems()
      @fails.push(spec: spec.getFullName(), description: item.toString(), link: @paramsFor(spec.getFullName()), trace: item.trace.stack || item.trace.toString())


  paramsFor: (description) ->
    "?grep=#{encodeURIComponent(description)}"


  setFilter: ->


  log: (obj = {}) ->
    obj["_teabag"] = true
    console.log(JSON.stringify(obj))



class Teabag.Reporters.HTML extends Teabag.View

  constructor: ->
    @start = Date.now()
    @config = {"use-catch": true, "build-full-report": false}
    @total = {exist: 0, run: 0, passes: 0, failures: 0, skipped: 0}
    @views = {specs: {}, suites: {}}
    @elements = {}
    @filter = false
    @readConfig()
    super


  build: ->
    @el = @findEl("report-all")
    @setText("env-info", @envInfo())
    @findEl("toggles").onclick = @toggleConfig
    @showConfiguration()

    try
      ratio = window.devicePixelRatio || 1
      @ctx = @findEl("progress-canvas").getContext("2d")
      @ctx.scale(ratio, ratio)
    catch e # intentionally do nothing


  reportRunnerStarting: (runner) ->
    @total.exist = runner.total || runner.specs().length
    @setText("stats-duration", "...") if @total.exist


  reportSpecStarting: (spec) ->
    @reportView = new Teabag.Reporters.HTML.SpecView(spec, @) if @config["build-full-report"]
    @specStart = Date.now()


  reportSpecResults: (spec) ->
    @total.run += 1
    @updatePercent()
    @updateStatus(spec)


  updateStatus: (spec) ->
    result = @resultForSpec(spec)

    if result.skipped
      @setText("stats-skipped", @total.skipped += 1)
      return

    elapsed = Date.now() - @specStart
    if result.passed
      @setText("stats-passes", @total.passes += 1)
      @reportView?.updateState("passed", elapsed)
    else
      @setText("stats-failures", @total.failures += 1)
      @reportView?.updateState("failed", elapsed)
      new Teabag.Reporters.HTML.FailureView(spec).appendTo(@findEl("report-failures")) unless @config["build-full-report"]
      @setStatus("failed")


  resultForSpec: (spec) ->
    result = spec.results()
    skipped: result.skipped
    passed: result.passed()


  reportRunnerResults: =>
    return unless @total.run
    @setText("stats-duration", "#{((Date.now() - @start) / 1000).toFixed(3)}s")
    @setStatus("passed") unless @total.failures
    if @total.run < @total.exist
      @total.skipped = @total.exist - @total.run
      @total.run = @total.exist
    @setText("stats-skipped", @total.skipped)
    @updatePercent()


  showConfiguration: ->
    @setClass(key, if value then "active" else "") for key, value of @config


  updatePercent: ->
    percent = if @total.exist then Math.ceil((@total.run * 100) / @total.exist) else 0
    @setHtml("progress-percent", "#{percent}%")
    return unless @ctx
    size = 80
    half = size / 2
    @ctx.strokeStyle = "#fff"
    @ctx.lineWidth = 1.5
    @ctx.clearRect(0, 0, size, size)
    @ctx.beginPath()
    @ctx.arc(half, half, half - 1, 0, Math.PI * 2 * (percent / 100), false)
    @ctx.stroke()


  setStatus: (status) ->
    document.body.className = "teabag-#{status}"


  setFilter: (filter) ->
    return unless filter
    @setClass("filtered", "teabag-filtered")
    @setHtml("filtered", "#{filter}", true)


  readConfig: ->
    @config = JSON.parse(config) if config = @cookie("teabag")


  toggleConfig: (e) =>
    button = e.target
    return unless button.tagName.toLowerCase() == "button"
    name = button.getAttribute("id").replace(/^teabag-/, "")
    @config[name] = !@config[name]
    @cookie("teabag", JSON.stringify(@config))
    if name == "use-catch" || name == "build-full-report"
      window.location.href = window.location.href
      return
    @readConfig()
    @showConfiguration()


  cookie: (name, value = undefined) ->
    if value == undefined
      name = name.replace(/([.*+?^=!:${}()|[\]\/\\])/g, "\\$1")
      match = document.cookie.match(new RegExp("(?:^|;)\\s?#{name}=(.*?)(?:;|$)", "i"))
      match && unescape(match[1]).split(' ')[0]
    else
      document.cookie = "#{name}=null"
      date = new Date()
      date.setDate(date.getDate() + 365)
      document.cookie = "#{name}=#{escape(value)} expires=#{date.toUTCString()};"



class Teabag.Reporters.HTML.FailureView extends Teabag.View

  constructor: (@spec) ->
    super


  build: ->
    super("spec")
    html = """<h1 class="teabag-clearfix"><a href="?grep=#{encodeURIComponent(@fullName())}">#{@fullName()}</a></h1>"""
    @el.innerHTML = html + @buildErrors()


  buildErrors: ->
    html = ""
    for error in @errors()
      html += """<div>#{error.stack || error.message || "Stack trace unavailable"}</div>"""


  fullName: ->
    @spec.getFullName()


  errors: ->
    for item in @spec.results().getItems()
      item.trace



class Teabag.Reporters.HTML.SpecView extends Teabag.View

  viewId = 0

  constructor: (@spec, @reporter) ->
    @views = @reporter.views
    viewId += 1
    @spec.viewId = viewId
    @views.specs[@spec.viewId] = @
    super


  build: ->
    super("spec")
    @el.innerHTML = """<a href="#{@link()}">#{@description()}</a>"""
    @parentView = @buildParent()
    @parentView.append(@el)


  buildParent: ->
    parent = @parent()
    if parent.viewId
      @views.suites[parent.viewId]
    else
      view = new Teabag.Reporters.HTML.SuiteView(parent, @reporter)
      @views.suites[view.suite.viewId] = view


  buildErrors: ->
    div = @createEl("div")
    html = ""
    for error in @errors()
      html += """#{error.stack || error.message || "Stack trace unavailable"}"""
    div.innerHTML = html
    @append(div)


  updateState: (state, elapsed) ->
    classes = ["state-#{state}"]
    classes.push("slow") if elapsed > Teabag.slow
    @el.innerHTML += "<span>#{elapsed}ms</span>" unless state == "failed"
    @el.className = classes.join(" ")
    @buildErrors() unless @passed()
    @parentView.updateState?(state)


  parent: ->
    @spec.suite


  link: ->
    "?grep=#{encodeURIComponent(@fullName())}"


  description: ->
    @spec.description


  fullName: ->
    @spec.getFullName()


  passed: ->
    @spec.results().passed()


  errors: ->
    for item in @spec.results().getItems()
      item.trace



class Teabag.Reporters.HTML.SuiteView extends Teabag.View

  viewId = 0

  constructor: (@suite, @reporter) ->
    @views = @reporter.views
    viewId += 1
    @suite.viewId = viewId
    @views.suites[@suite.viewId] = @
    super


  build: ->
    super("suite")
    @el.innerHTML = """<h1><a href="#{@link()}">#{@description()}</a></h1>"""
    @parentView = @buildParent()
    @parentView.append(@el)


  buildParent: ->
    parent = @parent()
    return @reporter unless parent
    if parent.viewId
      @views.suites[parent.viewId]
    else
      view = new Teabag.Reporters.HTML.SuiteView(parent, @reporter)
      @views.suites[view.suite.viewId] = view


  append: (el) ->
    super(@ol = @createEl("ol")) unless @ol
    @ol.appendChild(el)


  updateState: (state) ->
    return if @state == "failed"
    @el.className = "#{@el.className.replace(/\s?state-\w+/, "")} state-#{state}"
    @parentView.updateState?(state)
    @state = state


  parent: ->
    @suite.parentSuite


  link: ->
    "?grep=#{encodeURIComponent(@fullName())}"


  description: ->
    @suite.description


  fullName: ->
    @suite.getFullName()
