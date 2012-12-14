class Teabag.Reporters.HTML extends Teabag.Reporters.BaseView

  constructor: ->
    @start = new Teabag.Date().getTime()
    @config = {"use-catch": true, "build-full-report": false, "display-progress": true}
    @total = {exist: 0, run: 0, passes: 0, failures: 0, skipped: 0}
    @views = {specs: {}, suites: {}}
    @elements = {}
    @filter = false
    @readConfig()
    super


  build: ->
    @buildLayout()
    @el = @findEl("report-all")
    @setText("env-info", @envInfo())
    @findEl("toggles").onclick = @toggleConfig
    @showConfiguration()
    @buildProgress()


  buildLayout: ->
    el = @createEl("div")
    document.body.appendChild(el)
    el.innerHTML = """
      <div class="teabag-clearfix">
        <div id="teabag-title">
          <h1>Teabag</h1>
          <ul>
            <li>version: <b><%= Teabag::VERSION %></b></li>
            <li id="teabag-env-info"></li>
          </ul>
        </div>
        <div id="teabag-progress"></div>
        <ul id="teabag-stats">
          <li>passes: <b id="teabag-stats-passes">0</b></li>
          <li>failures: <b id="teabag-stats-failures">0</b></li>
          <li>skipped: <b id="teabag-stats-skipped">0</b></li>
          <li>duration: <b id="teabag-stats-duration">&infin;</b></li>
        </ul>
      </div>

      <div id="teabag-controls" class="teabag-clearfix">
        <div id="teabag-toggles">
          <button id="teabag-use-catch">Use Try/Catch</button>
          <button id="teabag-build-full-report">Build Full Report</button>
          <button id="teabag-display-progress">Display Progress</button>
        </div>
        <div id="teabag-filtered">
          <button onclick="window.location.href = window.location.pathname">Run All Specs</button>
        </div>
      </div>

      <hr/>

      <div id="teabag-report">
        <ol id="teabag-report-failures"></ol>
        <ol id="teabag-report-all"></ol>
      </div>
    """


  buildProgress: ->
    if !@config["display-progress"]
      @progress = new Teabag.Reporters.HTML.NoProgressView()
    else
      if Teabag.Reporters.HTML.RadialProgressView.supported
        @progress = new Teabag.Reporters.HTML.RadialProgressView()
      else
        @progress = new Teabag.Reporters.HTML.SimpleProgressView()
    @progress.appendTo(@findEl("progress"))


  reportRunnerStarting: (runner) ->
    @total.exist = runner.total || runner.specs().length
    @setText("stats-duration", "...") if @total.exist


  reportSpecStarting: (spec) ->
    spec = new Teabag.Reporters.NormalizedSpec(spec)
    @reportView = new Teabag.Reporters.HTML.SpecView(spec, @) if @config["build-full-report"]
    @specStart = new Teabag.Date().getTime()


  reportSpecResults: (spec) ->
    @total.run += 1
    @updateProgress()
    @updateStatus(spec)


  reportRunnerResults: =>
    return unless @total.run
    @setText("stats-duration", "#{((new Teabag.Date().getTime() - @start) / 1000).toFixed(3)}s")
    @setStatus("passed") unless @total.failures
    @setText("stats-passes", @total.passes)
    @setText("stats-failures", @total.failures)
    @setText("stats-skipped", @total.skipped)
    if @total.run < @total.exist
      @total.skipped = @total.exist - @total.run
      @total.run = @total.exist
    @setText("stats-skipped", @total.skipped)
    @updateProgress()


  updateStat: (name, value, force = false) ->
    return unless @config["display-progress"]
    @setText("stats-#{name}", value)


  updateStatus: (spec) ->
    spec = new Teabag.Reporters.NormalizedSpec(spec)
    result = spec.result()

    if result.skipped || result.status == "pending"
      @updateStat("skipped", @total.skipped += 1)
      return

    elapsed = new Teabag.Date().getTime() - @specStart

    if result.status == "passed"
      @updateStat("passes", @total.passes += 1)
      @reportView?.updateState("passed", elapsed)
    else
      @updateStat("failures", @total.failures += 1)
      @reportView?.updateState("failed", elapsed)
      new Teabag.Reporters.HTML.FailureView(spec).appendTo(@findEl("report-failures")) unless @config["build-full-report"]
      @setStatus("failed")


  updateProgress: ->
    @progress.update(@total.exist, @total.run)


  showConfiguration: ->
    @setClass(key, if value then "active" else "") for key, value of @config


  setStatus: (status) ->
    document.body.className = "teabag-#{status}"


  setFilter: (filter) ->
    return unless filter
    @setClass("filtered", "teabag-filtered")
    @setHtml("filtered", "#{filter}", true)


  readConfig: ->
    @config = config if config = @cookie("teabag")


  toggleConfig: (e) =>
    button = e.target
    return unless button.tagName.toLowerCase() == "button"
    name = button.getAttribute("id").replace(/^teabag-/, "")
    @config[name] = !@config[name]
    @cookie("teabag", @config)
    window.location.href = window.location.href


  cookie: (name, value = undefined) ->
    if value == undefined
      name = name.replace(/([.*+?^=!:${}()|[\]\/\\])/g, "\\$1")
      match = document.cookie.match(new RegExp("(?:^|;)\\s?#{name}=(.*?)(?:;|$)", "i"))
      match && JSON.parse(unescape(match[1]).split(" ")[0])
    else
      date = new Teabag.Date()
      date.setDate(date.getDate() + 365)
      document.cookie = "#{name}=#{escape(JSON.stringify(value))}; path=/; expires=#{date.toUTCString()};"



class Teabag.Reporters.HTML.NoProgressView extends Teabag.Reporters.BaseView

  build: ->
    @el = @createEl("div", "teabag-indicator modeset-logo")


  update: ->
    # do nothing



class Teabag.Reporters.HTML.SimpleProgressView extends Teabag.Reporters.HTML.NoProgressView

  build: ->
    @el = @createEl("div", "simple-progress")
    @el.innerHTML = """
      <em id="teabag-progress-percent">0%</em>
      <span id="teabag-progress-span" class="teabag-indicator"></span>
    """


  update: (total, run) ->
    percent = if total then Math.ceil((run * 100) / total) else 0
    @setHtml("progress-percent", "#{percent}%")



class Teabag.Reporters.HTML.RadialProgressView extends Teabag.Reporters.HTML.NoProgressView

  @supported: !!document.createElement("canvas").getContext

  build: ->
    @el = @createEl("div", "teabag-indicator radial-progress")
    @el.innerHTML = """
      <canvas id="teabag-progress-canvas"></canvas>
      <em id="teabag-progress-percent">0%</em>
    """

  appendTo: ->
    super
    @size = 80
    try
      canvas = @findEl("progress-canvas")
      canvas.width = canvas.height = canvas.style.width = canvas.style.height = @size
      @ctx = canvas.getContext("2d")
      @ctx.strokeStyle = "#fff"
      @ctx.lineWidth = 1.5
    catch e # intentionally do nothing


  update: (total, run) ->
    percent = if total then Math.ceil((run * 100) / total) else 0
    @setHtml("progress-percent", "#{percent}%")
    return unless @ctx
    half = @size / 2
    @ctx.clearRect(0, 0, @size, @size)
    @ctx.beginPath()
    @ctx.arc(half, half, half - 1, 0, Math.PI * 2 * (percent / 100), false)
    @ctx.stroke()



class Teabag.Reporters.HTML.FailureView extends Teabag.Reporters.BaseView

  constructor: (@spec) ->
    super


  build: ->
    super("spec")
    html = """<h1 class="teabag-clearfix"><a href="#{@spec.link}">#{@spec.fullDescription}</a></h1>"""
    for error in @spec.errors()
      html += """<div>#{@htmlSafe(error.stack || error.message || "Stack trace unavailable")}</div>"""
    @el.innerHTML = html



class Teabag.Reporters.HTML.SpecView extends Teabag.Reporters.BaseView

  viewId = 0

  constructor: (@spec, @reporter) ->
    @views = @reporter.views
    @spec.viewId = viewId += 1
    @views.specs[@spec.viewId] = @
    super


  build: ->
    classes = ["spec"]
    classes.push("state-pending") if @spec.pending
    super(classes.join(" "))
    @el.innerHTML = """<a href="#{@spec.link}">#{@spec.description}</a>"""
    @parentView = @buildParent()
    @parentView.append(@el)


  buildParent: ->
    parent = @spec.parent
    if parent.viewId
      @views.suites[parent.viewId]
    else
      view = new Teabag.Reporters.HTML.SuiteView(parent, @reporter)
      @views.suites[view.suite.viewId] = view


  buildErrors: ->
    div = @createEl("div")
    html = ""
    for error in @spec.errors()
      html += """#{@htmlSafe(error.stack || error.message || "Stack trace unavailable")}"""
    div.innerHTML = html
    @append(div)


  updateState: (state, elapsed) ->
    result = @spec.result()
    classes = ["state-#{state}"]
    classes.push("slow") if elapsed > Teabag.slow
    @el.innerHTML += "<span>#{elapsed}ms</span>" unless state == "failed"
    @el.className = classes.join(" ")
    @buildErrors() unless result.status == "passed"
    @parentView.updateState?(state)



class Teabag.Reporters.HTML.SuiteView extends Teabag.Reporters.BaseView

  viewId = 0

  constructor: (@suite, @reporter) ->
    @views = @reporter.views
    @suite.viewId = viewId += 1
    @views.suites[@suite.viewId] = @
    @suite = new Teabag.Reporters.NormalizedSuite(suite)
    super


  build: ->
    super("suite")
    @el.innerHTML = """<h1><a href="#{@suite.link}">#{@suite.description}</a></h1>"""
    @parentView = @buildParent()
    @parentView.append(@el)


  buildParent: ->
    parent = @suite.parent
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
