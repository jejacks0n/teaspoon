describe "Teaspoon.Reporters.HTML", ->

  beforeEach ->
    @originalParams = Teaspoon.params
    @buildSpy = spyOn(Teaspoon.Reporters.HTML.prototype, "build")
    @readConfigSpy = spyOn(Teaspoon.Reporters.HTML.prototype, "readConfig")
    Teaspoon.params = grep: "foo"
    @reporter = new Teaspoon.Reporters.HTML()
    @jasmineSuite = {getFullName: -> "_full jasmine suite description_"}
    @jasmineSpecResultsItems = [
      {message: "_jasmine_message1_", trace: {stack: "_jasmine_stack_trace1_"}, passed: -> false}
      {message: "_jasmine_message2_", trace: {stack: "_jasmine_stack_trace2_"}, passed: -> false}
    ]
    @jasmineSpecResults =
      skipped: false
      passed: -> true
      getItems: => @jasmineSpecResultsItems
    @jasmineSpec =
      description: "_jasmine_description_"
      viewId: 42
      pending: false
      suite: @jasmineSuite
      getFullName: -> "_full jasmine description_"
      results: => @jasmineSpecResults

  afterEach ->
    Teaspoon.params = @originalParams

  describe "constructor", ->

    it "sets up the expected variables", ->
      expect(@reporter.start).toBeDefined()
      expect(@reporter.config).toEqual("use-catch": true, "build-full-report": false, "display-progress": true)
      expect(@reporter.total).toEqual({exist: 0, run: 0, passes: 0, failures: 0, skipped: 0})
      expect(@reporter.views).toEqual({specs: {}, suites: {}})
      expect(@reporter.filters).toEqual(["by match: foo"])

    it "calls readConfig", ->
      expect(@readConfigSpy).toHaveBeenCalled()


  describe "#build", ->

    beforeEach ->
      @el = {}
      @buildSpy.andCallThrough()
      @buildLayoutSpy = spyOn(@reporter, "buildLayout")
      @findElSpy = spyOn(@reporter, "findEl").andReturn(@el)
      @setTextSpy = spyOn(@reporter, "setText")
      @showConfigurationSpy = spyOn(@reporter, "showConfiguration")
      @buildProgressSpy = spyOn(@reporter, "buildProgress")
      @buildSuiteSelectSpy = spyOn(@reporter, "buildSuiteSelect")
      @buildFiltersSpy = spyOn(@reporter, "buildFilters")
      spyOn(@reporter, "envInfo").andReturn("library 1.0.0")
      @reporter.build()

    it "calls buildLayout", ->
      expect(@buildLayoutSpy).toHaveBeenCalled()

    it "finds the element and assigns it", ->
      expect(@findElSpy).toHaveBeenCalledWith("report-all")
      expect(@reporter.el).toBe(@el)

    it "sets the env-info and version", ->
      expect(@setTextSpy).toHaveBeenCalledWith("env-info", "library 1.0.0")
      expect(@setTextSpy).toHaveBeenCalledWith("version", Teaspoon.version)

    it "makes the toggles clickable", ->
      expect(@findElSpy).toHaveBeenCalledWith("toggles")
      expect(@el.onclick).toBe(@reporter.toggleConfig)

    it "calls showConfiguration", ->
      expect(@showConfigurationSpy).toHaveBeenCalled()

    it "calls buildProgress", ->
      expect(@buildProgressSpy).toHaveBeenCalled()

    it "calls buildSuiteSelect", ->
      expect(@buildSuiteSelectSpy).toHaveBeenCalled()

    it "calls buildFilters", ->
      expect(@buildFiltersSpy).toHaveBeenCalled()


  describe "#buildLayout", ->

    beforeEach ->
      @el = {}
      @createElSpy = spyOn(@reporter, "createEl").andReturn(@el)
      @appendChildSpy = spyOn(document.body, "appendChild")
      @reporter.buildLayout()


    it "creates an element and appends it to the body", ->
      expect(@createElSpy).toHaveBeenCalledWith("div")
      expect(@appendChildSpy).toHaveBeenCalledWith(@el)
      expect(@el.innerHTML).toContain("Teaspoon")


  describe "#buildSuiteSelect", ->

    beforeEach ->
      @originalSuites = Teaspoon.suites
      Teaspoon.suites = {all: ["default", "foo", "bar"], active: "foo"}

    afterEach ->
      Teaspoon.suites = @originalSuites

    it "builds a select that displays the suites", ->
      result = @reporter.buildSuiteSelect()
      expect(result).toContain("select id=")
      expect(result).toContain("selected value=\"#{Teaspoon.root}/foo\"")


  describe "#buildProgress", ->

    beforeEach ->
      @progress = {appendTo: ->}
      @findElSpy = spyOn(@reporter, "findEl").andReturn("_element_")
      @createSpy = spyOn(Teaspoon.Reporters.HTML.ProgressView, "create").andReturn(@progress)
      @appendToSpy = spyOn(@progress, "appendTo")
      @reporter.buildProgress()

    it "calls create on ProgressView", ->
      expect(@createSpy).toHaveBeenCalledWith(true)

    it "appends the progress element to the dom", ->
      expect(@appendToSpy).toHaveBeenCalledWith("_element_")


  describe "#reportRunnerStarting", ->

    beforeEach ->
      @setTextSpy = spyOn(@reporter, "setText")
      @reporter.reportRunnerStarting(total: 42)

    it "gets the totals", ->
      expect(@reporter.total.exist).toBe(42)

    it "sets the duration text", ->
      expect(@setTextSpy).toHaveBeenCalledWith("stats-duration", "...")


  describe "#reportSpecStarting", ->

    it "creates a SpecView", ->
      @reporter.config["build-full-report"] = true
      spy = spyOn(Teaspoon.Reporters.HTML, "SpecView")
      @reporter.reportSpecStarting(@jasmineSpec)
      expect(spy).toHaveBeenCalled()

    it "doesn't create the SpecView if we're not building the full report", ->
      @reporter.config["build-full-report"] = false
      spy = spyOn(Teaspoon.Reporters.HTML, "SpecView")
      @reporter.reportSpecStarting(@jasmineSpec)
      expect(spy).wasNotCalled()

    it "tracks the start time of the spec", ->
      @reporter.specStart = undefined
      @reporter.reportSpecStarting(@jasmineSpec)
      expect(@reporter.specStart).toBeDefined()


  describe "#reportSpecResults", ->

    beforeEach ->
      @updateProgressSpy = spyOn(@reporter, "updateProgress")
      @updateStatusSpy = spyOn(@reporter, "updateStatus")

    it "increases the total run count", ->
      @reporter.total.run = 41
      @reporter.reportSpecResults(@jasmineSpec)
      expect(@reporter.total.run).toBe(42)

    it "calls updateProgress", ->
      @reporter.reportSpecResults(@jasmineSpec)
      expect(@updateProgressSpy).toHaveBeenCalled()

    it "calls updateStatus", ->
      @reporter.reportSpecResults(@jasmineSpec)
      expect(@updateStatusSpy).toHaveBeenCalledWith(@jasmineSpec)


  describe "#reportRunnerResults", ->

    beforeEach ->
      @setTextSpy = spyOn(@reporter, "setText")
      @setStatusSpy = spyOn(@reporter, "setStatus")
      @updateProgressSpy = spyOn(@reporter, "updateProgress")
      @elapsedTimeSpy = spyOn(@reporter, "elapsedTime").andReturn("1.000s")
      @reporter.total = {run: 666, exist: 42, failures: 5, passes: 10, skipped: 15}

    it "does nothing if there were no tests run", ->
      @reporter.total.run = 0
      @reporter.reportRunnerResults()
      expect(@setTextSpy).wasNotCalled()

    it "sets the duration text", ->
      @reporter.total = {run: 666, exist: 42}
      @reporter.reportRunnerResults()
      expect(@setTextSpy).toHaveBeenCalledWith("stats-duration", "1.000s")

    it "sets the status to passed if there are no failures", ->
      @reporter.total.failures = 0
      @reporter.reportRunnerResults()
      expect(@setStatusSpy).toHaveBeenCalledWith("passed")

    it "displays the total passes", ->
      @reporter.reportRunnerResults()
      expect(@setTextSpy).toHaveBeenCalledWith("stats-passes", 10)

    it "displays the total failures", ->
      @reporter.reportRunnerResults()
      expect(@setTextSpy).toHaveBeenCalledWith("stats-failures", 5)

    it "displays the total skipped", ->
      @reporter.reportRunnerResults()
      expect(@setTextSpy).toHaveBeenCalledWith("stats-skipped", 15)

    it "calls updateProgress", ->
      @reporter.reportRunnerResults()
      expect(@updateProgressSpy).toHaveBeenCalled()


  describe "#updateStat", ->

    beforeEach ->
      @setTextSpy = spyOn(@reporter, "setText")

    it "does nothing if we're not displaying progress", ->
      @reporter.config["display-progress"] = false
      @reporter.updateStat("name", 42)
      expect(@setTextSpy).wasNotCalled()


    it "sets the text of the stat we want to set", ->
      @reporter.updateStat("name", 42)
      expect(@setTextSpy).toHaveBeenCalledWith("stats-name", 42)


  describe "#updateStatus", ->

    beforeEach ->
      @updateStatSpy = spyOn(@reporter, "updateStat")
      @setStatusSpy = spyOn(@reporter, "setStatus")
      @findElSpy = spyOn(@reporter, "findEl").andReturn(appendChild: ->)

    describe "skipped", ->

      it "updates the statistic", ->
        @jasmineSpecResults.skipped = true
        @reporter.updateStatus(@jasmineSpec)
        expect(@updateStatSpy).toHaveBeenCalledWith("skipped", 1)

    describe "pass", ->

      it "updates the statistic", ->
        @reporter.updateStatus(@jasmineSpec)
        expect(@updateStatSpy).toHaveBeenCalledWith("passes", 1)

      it "calls updateState on the view", ->
        @reporter.reportView = updateState: ->
        spy = spyOn(@reporter.reportView, "updateState")
        @reporter.updateStatus(@jasmineSpec)
        expect(spy.argsForCall[0][0]).toBe("passed")

    describe "failure", ->

      beforeEach ->
        @jasmineSpecResults.passed = -> false

      it "updates the statistic", ->
        @reporter.updateStatus(@jasmineSpec)
        expect(@updateStatSpy).toHaveBeenCalledWith("failures", 1)

      it "calls updateState on the view", ->
        @reporter.reportView = updateState: ->
        spy = spyOn(@reporter.reportView, "updateState")
        @reporter.updateStatus(@jasmineSpec)
        expect(spy.argsForCall[0][0]).toBe("failed")

      it "creates a FailureView and appends it to the dom", ->
        spy = spyOn(Teaspoon.Reporters.HTML, "FailureView").andReturn(appendTo: ->)
        @reporter.updateStatus(@jasmineSpec)
        expect(spy).toHaveBeenCalled()

      it "doesn't create a FailureView if we're building the full report", ->
        @reporter.config["build-full-report"] = true
        spy = spyOn(Teaspoon.Reporters.HTML, "FailureView").andReturn(appendTo: ->)
        @reporter.updateStatus(@jasmineSpec)
        expect(spy).wasNotCalled()

      it "sets the status", ->
        @reporter.updateStatus(@jasmineSpec)
        expect(@setStatusSpy).toHaveBeenCalledWith("failed")


  describe "#updateProgress", ->

    beforeEach ->
      @progress = {update: ->}
      @updateSpy = spyOn(@progress, "update")
      @reporter.progress = @progress
      @reporter.total = {exist: 666, run: 42}
      @reporter.updateProgress()

    it "calls update on the progress view", ->
      expect(@updateSpy).toHaveBeenCalledWith(666, 42)


  describe "#showConfiguration", ->

    beforeEach ->
      @setClassSpy = spyOn(@reporter, "setClass")

    it "sets the class to active on the toggle buttons for each configuration", ->
      @reporter.showConfiguration()
      expect(@setClassSpy).toHaveBeenCalledWith("use-catch", "active")
      expect(@setClassSpy).toHaveBeenCalledWith("build-full-report", "")
      expect(@setClassSpy).toHaveBeenCalledWith("display-progress", "active")


  describe "#setStatus", ->

    it "sets the body class to the status passed in", ->
      current = document.body.className
      @reporter.setStatus("foo")
      expect(document.body.className).toBe("teaspoon-foo")
      document.body.className = current


  describe "#setFilter", ->

    beforeEach ->
      Teaspoon.params = grep: "_grep_", file: "_file_"
      @reporter.filters = []
      @reporter.setFilters()

    it "sets a class and the html for the filter display", ->
      expect(@reporter.filters.length).toBe(2)
      expect(@reporter.filters[0]).toBe("by file: _file_")
      expect(@reporter.filters[1]).toBe("by match: _grep_")


  describe "#readConfig", ->

    beforeEach ->
      @readConfigSpy.andCallThrough()
      @config = {}
      @storeSpy = spyOn(@reporter, "store").andReturn(@config)
      @reporter.readConfig()

    it "reads the configuration from the cookie", ->
      expect(@storeSpy).toHaveBeenCalledWith("teaspoon")
      expect(@reporter.config).toEqual(@config)


  describe "#toggleConfig", ->

    beforeEach ->
      @refreshSpy = spyOn(Teaspoon, "reload")
      @storeSpy = spyOn(@reporter, "store")
      @reporter.toggleConfig(target: {tagName: "button", getAttribute: -> "teaspoon-use-catch"})

    it "toggles the configuration", ->
      expect(@reporter.config["use-catch"]).toBe(false)

    it "sets the cookie", ->
      expect(@storeSpy).toHaveBeenCalledWith("teaspoon", @reporter.config)

    it "refreshes the page", ->
      expect(@refreshSpy).toHaveBeenCalled()
