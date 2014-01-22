(function() {
  var system = require("system");
  var webpage = require("webpage");

  this.Runner = (function() {

    function Runner() {
      this.url = system.args[1];
      this.timeout = parseInt(system.args[2] || 180) * 1000;

      var _this = this;
      this.waitForResults = function() { Runner.prototype.waitForResults.apply(_this, arguments) };
    }

    Runner.prototype.run = function() {
      this.initPage();
      this.loadPage();
    };

    Runner.prototype.initPage = function() {
      this.page = webpage.create();
      this.page.viewportSize = {
        width: 800,
        height: 800
      };
    };

    Runner.prototype.loadPage = function() {
      var method, name, _ref, _results;
      this.page.open(this.url);
      _ref = this.pageCallbacks();
      _results = [];
      for (name in _ref) {
        method = _ref[name];
        _results.push(this.page[name] = method);
      }
      return _results;
    };

    Runner.prototype.waitForResults = function() {
      if ((new Date().getTime() - this.start) >= this.timeout) this.fail("Timed out");
      var finished = this.page.evaluate(function() { return window.Teaspoon && window.Teaspoon.finished });
      finished ? this.finish() : setTimeout(this.waitForResults, 200);
    };

    Runner.prototype.fail = function(msg, errno) {
      if (msg == null) msg = null;
      if (errno == null) errno = 1;
      if (msg) console.log("Error: " + msg);

      console.log(JSON.stringify({
        _teaspoon: true,
        type: "exception"
      }));
      phantom.exit(errno);
    };

    Runner.prototype.finish = function() {
      console.log(" ");
      phantom.exit(0);
    };

    Runner.prototype.pageCallbacks = function() {
      var _this = this;
      return {
        onError: function(message, trace) {
          console.log(JSON.stringify({
            _teaspoon: true,
            type: "error",
            message: message,
            trace: trace
          }));
          _this.errored = true;
        },

        onConsoleMessage: function(msg) {
          console.log(msg);
          if (_this.errorTimeout) clearTimeout(_this.errorTimeout);
          if (_this.errored) {
            _this.errorTimeout = setTimeout((function() {
              return _this.fail('Javascript error has cause a timeout.');
            }), 1000);
            return _this.errored = false;
          }
        },

        onLoadFinished: function(status) {
          if (_this.start) return;
          _this.start = new Date().getTime();
          var defined = _this.page.evaluate(function() {
            return window.Teaspoon;
          });
          if (!(status === "success" && defined)) {
            _this.fail("Failed to load: " + _this.url);
            return;
          }
          _this.waitForResults();
        }
      };
    };

    return Runner;

  })();

  new Runner().run();

}).call(this);
