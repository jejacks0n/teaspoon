#= require ../base

class Teabag.Reporters.HTML extends Teabag.View

  constructor: ->
    @start = Date.now()
    @config = {"use-catch": true, "build-full-report": false, "show-full-report": true}
    @total = {exist: 0, run: 0, passes: 0, failures: 0, skipped: 0}
    @views = {specs: {}, suites: {}}
    @elements = {}
    @setup()
    super


  setup: ->
    @config = JSON.parse(config) if config = @cookie("teabag")
    jasmine.CATCH_EXCEPTIONS = @config["use-catch"]


  build: ->
    @el = @findEl("report-all")
    @setText("env-info", @envInfo())
    @findEl("toggles").onclick = @toggle
    @showConfig()
    try
      ratio = window.devicePixelRatio || 1
      @ctx = @findEl("progress-canvas").getContext("2d")
      @ctx.scale(ratio, ratio)
    catch e # intentionally do nothing


  toggle: (e) =>
    button = e.target
    return unless button.tagName.toLowerCase() == "button"
    name = button.getAttribute("id").replace(/^teabag-/, "")
    @config[name] = !@config[name]
    @cookie("teabag", JSON.stringify(@config))
    window.location.href = window.location.href if name == "use-catch" || name == "build-full-report"
    @showConfig()


  showConfig: ->
    @setClass("report-all", if @config["show-full-report"] then "show-full" else "")
    @setClass(key, if value then "active" else "") for key, value of @config


  reportRunnerStarting: (runner) ->
    @total.exist = runner.specs().length
    @setText("stats-duration", "...") if @total.exist


  reportSpecStarting: (spec) ->
    # we have to pass ourself into the subviews because of the way Jasmine is setup
    # (a reportSuiteStaring would be nice)
    @reportView = new SpecView(spec, @) if @config["build-full-report"]


  reportSpecResults: (spec) ->
    @total.run += 1
    @updateStatus(spec)
    @updatePercent()


  reportRunnerResults: ->
    return unless @total.run
    @setText("stats-duration", "#{((Date.now() - @start) / 1000).toFixed(3)}s")
    @setStatus("passed") unless @total.failures
    @updatePercent()


  updateStatus: (spec) ->
    results = spec.results()

    if results.skipped
      @setText("stats-skipped", @total.skipped += 1)
      return

    if results.passed()
      @setText("stats-passes", @total.passes += 1)
      @reportView?.updateState("passed")
    else
      @setText("stats-failures", @total.failures += 1)
      @reportView?.updateState("failed")
      new FailureView(spec, @total.failures).appendTo(@findEl("report-failures"))
      @setStatus("failed")


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


  envInfo: ->
    ver = jasmine.getEnv().version()
    verString = [ver.major, ver.minor, ver.build].join(".")
    "jasmine #{verString} revision #{ver.revision}"


  cookie: (name, value = undefined) ->
    if value == undefined
      name = name.replace(/([.*+?^=!:${}()|[\]\/\\])/g, "\\$1")
      match = document.cookie.match(new RegExp("(?:^|;)\\s?#{name}=(.*?)(?:;|$)", "i"))
      match && unescape(match[1])
    else
      date = new Date()
      date.setDate(date.getDate() + 365)
      document.cookie = "#{name}=#{escape(value)}; expires=#{date.toUTCString()}"



class FailureView extends Teabag.View

  constructor: (@spec, @number) ->
    super


  build: ->
    super("spec")
    results = @spec.results()
    html = """<h1><a href="?grep=#{encodeURIComponent(@spec.getFullName())}">#{@spec.getFullName()}</a></h1>"""
    for error in results.getItems()
      html += """<div>#{error.trace.stack || error.message || "Stack trace unavailable"}</div>"""
    @el.innerHTML = html



class SpecView extends Teabag.View

  constructor: (@spec, @reporter) ->
    @views = @reporter.views
    @views.specs[@spec.id] = @
    super


  build: ->
    super("spec")
    @el.innerHTML = """<a href="?grep=#{encodeURIComponent(@spec.getFullName())}">#{@spec.description}</a>"""
    @parentView = @buildParent()
    @parentView.append(@el)


  buildParent: ->
    @views.suites[@spec.suite.id] ||= new SuiteView(@spec.suite, @reporter)


  updateState: (state) ->
    return if @state == "failed"
    @el.className = "#{@el.className.replace(/\s?state-\w+/, "")} state-#{state}"
    @parentView.updateState?(state)
    @state = state



class SuiteView extends Teabag.View

  constructor: (@suite, @reporter) ->
    @views = @reporter.views
    @views.suites[@suite.id] = @
    super


  build: ->
    super("suite")
    @el.innerHTML = """<h1><a href="?grep=#{encodeURIComponent(@suite.getFullName())}">#{@suite.description}</a></h1>"""
    @parentView = @buildParent()
    @parentView.append(@el)


  buildParent: ->
    if @suite.parentSuite
      @views.suites[@suite.parentSuite.id] ||= new SuiteView(@suite.parentSuite, @reporter)
    else
      @reporter


  append: (el) ->
    super(@ol = @createEl("ol")) unless @ol
    @ol.appendChild(el)


  updateState: (state) ->
    return if @state == "failed"
    @el.className = "#{@el.className.replace(/\s?state-\w+/, "")} state-#{state}"
    @parentView.updateState?(state)
    @state = state
