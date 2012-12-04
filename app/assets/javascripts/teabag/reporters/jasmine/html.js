
Teabag.HtmlReporterHelpers = {

  el: function(type, attrs, childrenVarArgs) {
    var el = document.createElement(type);

    for (var i = 2; i < arguments.length; i++) {
      var child = arguments[i];

      if (typeof child === 'string') {
        el.appendChild(document.createTextNode(child));
      } else {
        if (child) {
          el.appendChild(child);
        }
      }
    }

    for (var attr in attrs) {
      if (attr == "className") {
        el[attr] = attrs[attr];
      } else {
        el.setAttribute(attr, attrs[attr]);
      }
    }

    return el;
  },

  getSpecStatus: function(child) {
    var results = child.results();
    var status = results.passed() ? 'passed' : 'failed';
    if (results.skipped) {
      status = 'skipped';
    }

    return status;
  },

  appendToSummary: function(child, childElement) {
    var parentDiv = this.dom.summary;
    var parentSuite = (typeof child.parentSuite == 'undefined') ? 'suite' : 'parentSuite';
    var parent = child[parentSuite];

    if (parent) {
      if (typeof this.views.suites[parent.id] == 'undefined') {
        this.views.suites[parent.id] = new Teabag.HtmlReporter.SuiteView(parent, this.dom, this.views);
      }
      parentDiv = this.views.suites[parent.id].element;
    }

    parentDiv.appendChild(childElement);
  },

  addHelpers: function(ctor) {
    for(var fn in Teabag.HtmlReporterHelpers) {
      ctor.prototype[fn] = Teabag.HtmlReporterHelpers[fn];
    }
  }

};

Teabag.HtmlReporter = function(_doc) {
  var self = this;
  var doc = _doc || window.document;

  var reporterView;

  var dom = {};

  // Jasmine Reporter Public Interface
  self.logRunningSpecs = false;

  self.reportRunnerStarting = function(runner) {
    var specs = runner.specs() || [];

    if (specs.length == 0) {
      return;
    }

    createReporterDom(runner.env.versionString());
    doc.body.appendChild(dom.reporter);
    setExceptionHandling();

    reporterView = new Teabag.HtmlReporter.ReporterView(dom);
    reporterView.addSpecs(specs, self.specFilter);
  };

  self.reportRunnerResults = function(runner) {
    reporterView && reporterView.complete();
  };

  self.reportSuiteResults = function(suite) {
    reporterView.suiteComplete(suite);
  };

  self.reportSpecStarting = function(spec) {
    if (self.logRunningSpecs) {
      self.log('>> Jasmine Running ' + spec.suite.description + ' ' + spec.description + '...');
    }
  };

  self.reportSpecResults = function(spec) {
    reporterView.specComplete(spec);
  };

  self.log = function() {
    var console = jasmine.getGlobal().console;
    if (console && console.log) {
      if (console.log.apply) {
        console.log.apply(console, arguments);
      } else {
        console.log(arguments); // ie fix: console.log.apply doesn't exist on ie
      }
    }
  };

  self.specFilter = function(spec) {
    if (!focusedSpecName()) {
      return true;
    }

    return spec.getFullName().indexOf(focusedSpecName()) === 0;
  };

  return self;

  function focusedSpecName() {
    var specName;

    (function memoizeFocusedSpec() {
      if (specName) {
        return;
      }

      var paramMap = [];
      var params = Teabag.HtmlReporter.parameters(doc);

      for (var i = 0; i < params.length; i++) {
        var p = params[i].split('=');
        paramMap[decodeURIComponent(p[0])] = decodeURIComponent(p[1]);
      }

      specName = paramMap.spec;
    })();

    return specName;
  }

  function createReporterDom(version) {
    dom.reporter = self.el('div', { id: 'HTMLReporter', className: 'jasmine_reporter' },
        dom.banner = self.el('div', { className: 'banner' },
            self.el('span', { className: 'title' }, "Jasmine "),
            self.el('span', { className: 'version' }, version)),

        dom.symbolSummary = self.el('ul', {className: 'symbolSummary'}),
        dom.alert = self.el('div', {className: 'alert'},
            self.el('span', { className: 'exceptions' },
                self.el('label', { className: 'label', for: 'no_try_catch' }, 'No try/catch'),
                self.el('input', { id: 'no_try_catch', type: 'checkbox' }))),
        dom.results = self.el('div', {className: 'results'},
            dom.summary = self.el('div', { className: 'summary' }),
            dom.details = self.el('div', { id: 'details' }))
    );
  }

  function noTryCatch() {
    return window.location.search.match(/catch=false/);
  }

  function searchWithCatch() {
    var params = Teabag.HtmlReporter.parameters(window.document);
    var removed = false;
    var i = 0;

    while (!removed && i < params.length) {
      if (params[i].match(/catch=/)) {
        params.splice(i, 1);
        removed = true;
      }
      i++;
    }
    if (jasmine.CATCH_EXCEPTIONS) {
      params.push("catch=false");
    }

    return params.join("&");
  }

  function setExceptionHandling() {
    var chxCatch = document.getElementById('no_try_catch');

    if (noTryCatch()) {
      chxCatch.setAttribute('checked', true);
      jasmine.CATCH_EXCEPTIONS = false;
    }
    chxCatch.onclick = function() {
      window.location.search = searchWithCatch();
    };
  }
};

Teabag.HtmlReporter.parameters = function(doc) {
  var paramStr = doc.location.search.substring(1);
  var params = [];

  if (paramStr.length > 0) {
    params = paramStr.split('&');
  }
  return params;
}

Teabag.HtmlReporter.sectionLink = function(sectionName) {
  var link = '?';
  var params = [];

  if (sectionName) {
    params.push('spec=' + encodeURIComponent(sectionName));
  }
  if (!jasmine.CATCH_EXCEPTIONS) {
    params.push("catch=false");
  }
  if (params.length > 0) {
    link += params.join("&");
  }

  return link;
};
Teabag.HtmlReporterHelpers.addHelpers(Teabag.HtmlReporter);
