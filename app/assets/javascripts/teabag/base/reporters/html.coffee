#= require teabag/base/reporters/html/base_view
#= require_self
#= require teabag/base/reporters/html/progress_view
#= require teabag/base/reporters/html/spec_view
#= require teabag/base/reporters/html/failure_view
#= require teabag/base/reporters/html/suite_view
#= require teabag/base/reporters/html/template

class Teabag.Reporters.HTML extends Teabag.Reporters.BaseView

  constructor: ->
    @start = new Teabag.Date().getTime()
    @config = {"use-catch": true, "build-full-report": false, "display-progress": true}
    @total = {exist: 0, run: 0, passes: 0, failures: 0, skipped: 0}
    @views = {specs: {}, suites: {}}
    @filters = []
    @setFilters()
    @readConfig()
    super


  build: ->
    @buildLayout()

    @setText("env-info", @envInfo())
    @setText("version", Teabag.version)
    @findEl("toggles").onclick = @toggleConfig

    @findEl("suites").innerHTML = @buildSuiteSelect()
    @findEl("suite-select")?.onchange = @changeSuite

    @el = @findEl("report-all")

    @showConfiguration()
    @buildProgress()
    @buildFilters()


  buildLayout: ->
    el = @createEl("div")
    el.id = "teabag-interface"
    el.innerHTML = Teabag.Reporters.HTML.template
    document.body.appendChild(el)


  buildSuiteSelect: ->
    return "" if Teabag.suites.all.length == 1
    options = []
    for suite in Teabag.suites.all
      options.push("""<option#{if Teabag.suites.active == suite then " selected='selected'" else ""} value="#{suite}">#{suite}</option>""")
    """<select id="teabag-suite-select">#{options.join("")}</select>"""


  buildProgress: ->
    @progress = Teabag.Reporters.HTML.ProgressView.create(@config["display-progress"])
    @progress.appendTo(@findEl("progress"))


  buildFilters: ->
    @setClass("filter", "teabag-filtered") if @filters.length
    @setHtml("filter-list", "<li>#{@filters.join("</li><li>")}", true)


  reportRunnerStarting: (runner) ->
    @total.exist = runner.total || runner.specs().length
    @setText("stats-duration", "...") if @total.exist


  reportSpecStarting: (spec) ->
    spec = new Teabag.Spec(spec)
    @reportView = new Teabag.Reporters.HTML.SpecView(spec, @) if @config["build-full-report"]
    @specStart = new Teabag.Date().getTime()


  reportSpecResults: (spec) ->
    @total.run += 1
    @updateProgress()
    @updateStatus(spec)


  reportRunnerResults: =>
    return unless @total.run
    @setText("stats-duration", @elapsedTime())
    @setStatus("passed") unless @total.failures
    @setText("stats-passes", @total.passes)
    @setText("stats-failures", @total.failures)
    if @total.run < @total.exist
      @total.skipped = @total.exist - @total.run
      @total.run = @total.exist
    @setText("stats-skipped", @total.skipped)
    @updateProgress()


  elapsedTime: ->
    "#{((new Teabag.Date().getTime() - @start) / 1000).toFixed(3)}s"


  updateStat: (name, value) ->
    return unless @config["display-progress"]
    @setText("stats-#{name}", value)


  updateStatus: (spec) ->
    spec = new Teabag.Spec(spec)
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


  setFilters: ->
    link = [Teabag.root, Teabag.suites.active].join('/')
    @filters.push("<a href='#{link}'>remove</a> by file: #{Teabag.params["file"]}") if Teabag.params["file"]
    @filters.push("<a href='#{link}'>remove</a> by match: #{Teabag.params["grep"]}") if Teabag.params["grep"]


  readConfig: ->
    @config = config if config = @cookie("teabag")


  toggleConfig: (e) =>
    button = e.target
    return unless button.tagName.toLowerCase() == "button"
    name = button.getAttribute("id").replace(/^teabag-/, "")
    @config[name] = !@config[name]
    @cookie("teabag", @config)
    @refresh()


  changeSuite: ->
    window.location.href = [Teabag.root, @options[@options.selectedIndex].value].join('/')


  refresh: ->
    window.location.href = window.location.href


  cookie: (name, value = undefined) ->
    if value == undefined
      name = name.replace(/([.*+?^=!:${}()|[\]\/\\])/g, "\\$1")
      match = document.cookie.match(new RegExp("(?:^|;)\\s?#{name}=(.*?)(?:;|$)", "i"))
      match && JSON.parse(unescape(match[1]).split(" ")[0])
    else
      date = new Teabag.Date()
      date.setDate(date.getDate() + 365)
      document.cookie = "#{name}=#{escape(JSON.stringify(value))}; expires=#{date.toUTCString()}; path=/;"
