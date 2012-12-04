
class Teabag.HtmlReporter.ReporterView

  constructor: (@dom) ->
    @startedAt = new Date()
    @runningSpecCount = 0
    @completeSpecCount = 0
    @passedCount = 0
    @failedCount = 0
    @skippedCount = 0


  createResultsMenu: ->
    @resultsMenu = @el 'span', {className: 'resultsMenu bar'},
                   @summaryMenuItem = @el('a', {className: 'summaryMenuItem', href: "#"}, '0 specs'),
                   ' | ',
                   @detailsMenuItem = @el('a', {className: 'detailsMenuItem', href: "#"}, '0 failing')

    @summaryMenuItem.onclick = => @dom.reporter.className = @dom.reporter.className.replace(/\s?showDetails/g, '')
    @detailsMenuItem.onclick = => @showDetails()


  showDetails: ->
    if @dom.reporter.className.search(/showDetails/) == -1
      @dom.reporter.className += " showDetails"


  addSpecs: (specs, specFilter) ->
    @totalSpecCount = specs.length
    @views = {specs: {}, suites: {}}

    for spec in specs
      @views.specs[spec.id] = new Teabag.HtmlReporter.SpecView(spec, @dom, @views)
      @runningSpecCount += 1 if specFilter(spec)


  specComplete: (spec) ->
    @completeSpecCount += 1
    specView = (@views.specs[spec.id] ||= new Teabag.HtmlReporter.SpecView(spec, @dom, @views))

    switch specView.status()
      when 'passed' then @passedCount += 1
      when 'skipped' then @skippedCount += 1
      else @failedCount += 1

    specView.refresh()
    @refresh()


  suiteComplete: (suite) ->
    @views.suites[suite.id]?.refresh()


  refresh: ->
    @createResultsMenu() if typeof(@resultsMenu) == 'undefined'

    # currently running UI
    unless @runningAlert
      @runningAlert = @el('a', {href: Teabag.HtmlReporter.sectionLink(), className: "runningAlert bar"})
      @dom.alert.appendChild(@runningAlert)
    @runningAlert.innerHTML = "Running #{@completeSpecCount} of #{@specPluralizedFor(@totalSpecCount)}"

    # skipped specs UI
    if typeof(@skippedAlert) == 'undefined'
      @skippedAlert = @el('a', {href: Teabag.HtmlReporter.sectionLink(), className: "skippedAlert bar"})
    @skippedAlert.innerHTML = "Skipping #{@skippedCount} of #{@specPluralizedFor(@totalSpecCount)} - run all"

    @dom.alert.appendChild(@skippedAlert) if @skippedCount == 1 && @dom.alert

    # passing specs UI
    unless @passedAlert
      @passedAlert = @el('span', {href: Teabag.HtmlReporter.sectionLink(), className: "passingAlert bar"})
    @passedAlert.innerHTML = "Passing #{@specPluralizedFor(@passedCount)}"

    # failing specs UI
    unless @failedAlert
      @failedAlert = @el('span', {href: "?", className: "failingAlert bar"})
    @failedAlert.innerHTML = "Failing #{@specPluralizedFor(@failedCount)}"

    if @failedCount == 1 && @dom.alert
      @dom.alert.appendChild(@failedAlert)
      @dom.alert.appendChild(@resultsMenu)

    # summary info
    @summaryMenuItem.innerHTML = @specPluralizedFor(@runningSpecCount)
    @detailsMenuItem.innerHTML = "#{@failedCount} failing"


  complete: ->
    @dom.alert.removeChild(@runningAlert)
    @skippedAlert.innerHTML = "Ran #{@runningSpecCount} of #{@specPluralizedFor(@totalSpecCount)} - run all"

    if @failedCount == 0
      @dom.alert.appendChild(@el('span', {className: 'passingAlert bar'}, "Passing #{@specPluralizedFor(@passedCount)}"))
    else
      @showDetails()

    @dom.banner.appendChild(@el('span', {className: 'duration'}, "finished in #{(new Date().getTime() - @startedAt.getTime()) / 1000}s"))


  specPluralizedFor: (count) ->
    "#{count} spec#{if count > 1 then 's' else ''}"



class Teabag.HtmlReporter.SuiteView

  constructor: (@suite, @dom, @views) ->
    @build()
    @appendToSummary(@suite, @element)


  build: ->
    @element = @el 'div', {className: 'suite'},
               @el 'a', {className: 'description', href: Teabag.HtmlReporter.sectionLink(@suite.getFullName())}, @suite.description


  status: ->
    @getSpecStatus(@suite)


  refresh: ->
    @element.className += " #{@status()}"



class Teabag.HtmlReporter.SpecView

  constructor: (@spec, @dom, @views) ->
    @build()


  build: ->
    @symbol  = @el 'li', {className: 'pending'}
    @summary = @el 'div', {className: 'specSummary'},
               @el 'a', {className: 'description', href: Teabag.HtmlReporter.sectionLink(@spec.getFullName()), title: @spec.getFullName()}, @spec.description
    @detail  = @el 'div', {className: 'specDetail'},
               @el 'a', {className: 'description', href: '?spec=' + encodeURIComponent(@spec.getFullName()), title: @spec.getFullName()}, @spec.getFullName()
    @dom.symbolSummary.appendChild(@symbol)


  status: ->
    @getSpecStatus(@spec)


  refresh: ->
    @symbol.className = @status()
    switch @status()
      when 'passed'
        @appendSummaryToSuiteDiv()
      when 'failed'
        @appendSummaryToSuiteDiv()
        @appendFailureDetail()


  appendSummaryToSuiteDiv: ->
    @summary.className += " #{@status()}"
    @appendToSummary(@spec, @summary)


  appendFailureDetail: ->
    @detail.className += " #{@status()}"
    messagesDiv = @el('div', {className: 'messages'})

    for result in @spec.results().getItems()
      if result.type == 'log'
        messagesDiv.appendChild(@el('div', {className: 'resultMessage log'}, result.toString()))
      else if result.type == 'expect' && result.passed && !result.passed()
        messagesDiv.appendChild(@el('div', {className: 'resultMessage fail'}, result.message))
      if result.trace.stack
        messagesDiv.appendChild(@el('div', {className: 'stackTrace'}, result.trace.stack))

    if messagesDiv.childNodes.length > 0
      @detail.appendChild(messagesDiv)
      @dom.details.appendChild(@detail)

Teabag.HtmlReporterHelpers.addHelpers(Teabag.HtmlReporter.ReporterView)
Teabag.HtmlReporterHelpers.addHelpers(Teabag.HtmlReporter.SuiteView)
Teabag.HtmlReporterHelpers.addHelpers(Teabag.HtmlReporter.SpecView)

