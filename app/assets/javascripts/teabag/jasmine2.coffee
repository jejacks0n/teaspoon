#= require jasmine-2.0.0
#= require teabag/base/teabag
#= require teabag/jasmine/fixture
#= require teabag/jasmine/reporters/html

class Teabag.Runner extends Teabag.Runner

  constructor: ->
    super
    jasmine.getEnv().execute()


#  setup: ->
#    env.updateInterval = 1000
#
#    # add the spec filter
#    if grep = @params["grep"]
#      env.specFilter = (spec) -> return spec.getFullName().indexOf(grep) == 0
#
#    # add the reporter and set the filter
#    reporter = new (@getReporter())()
#    env.addReporter(reporter)
#
#
#
#class Teabag.Spec
#
#  constructor: (@spec) ->
#    @fullDescription = @spec.getFullName()
#    @description = @spec.description
#    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
#    @parent = @spec.suite
#    @suiteName = @parent.getFullName()
#    @viewId = @spec.viewId
#    @pending = @spec.pending
#
#
#  errors: ->
#    return [] unless @spec.results
#    for item in @spec.results().getItems()
#      continue if item.passed()
#      {message: item.message, stack: item.trace.stack}
#
#
#  getParents: ->
#    return @parents if @parents
#    @parents ||= []
#    parent = @parent
#    while parent
#      parent = new Teabag.Suite(parent)
#      @parents.unshift(parent)
#      parent = parent.parent
#    @parents
#
#
#  result: ->
#    results = @spec.results()
#    status = "failed"
#    status = "passed" if results.passed()
#    status = "pending" if @spec.pending
#    status: status
#    skipped: results.skipped
#
#
#
#class Teabag.Suite
#
#  constructor: (@suite) ->
#    @fullDescription = @suite.getFullName()
#    @description = @suite.description
#    @link = "?grep=#{encodeURIComponent(@fullDescription)}"
#    @parent = @suite.parentSuite
#    @viewId = @suite.viewId
#
#
## set the environment
#env = jasmine.getEnv()



#  var htmlReporter = new jasmine.HtmlReporter({
#    env: env,
#    queryString: queryString,
#    onRaiseExceptionsClick: function() { queryString.setParam("catch", !env.catchingExceptions()); },
#    getContainer: function() { return document.body; },
#    createElement: function() { return document.createElement.apply(document, arguments); },
#    createTextNode: function() { return document.createTextNode.apply(document, arguments); }
#  });
#
#  env.addReporter(jasmineInterface.jsApiReporter);
#  env.addReporter(htmlReporter);
#
#  var specFilter = new jasmine.HtmlSpecFilter({
#    filterString: function() { return queryString.getParam("spec"); }
#  });
#
#  env.specFilter = function(spec) {
#    return specFilter.matches(spec.getFullName());
#  };
#
#  var currentWindowOnload = window.onload;
#
#  window.onload = function() {
#    if (currentWindowOnload) {
#      currentWindowOnload();
#    }
#    htmlReporter.initialize();
#    env.execute();
#  };
