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
      this.page.open(this.url);
      var callbacks = this.pageCallbacks();
      for (var name in callbacks) {
        this.page[name] = callbacks[name];
      }
    };

    Runner.prototype.waitForResults = function() {
      if ((new Date().getTime() - this.start) >= this.timeout) this.fail("Timed out");
      var finished = this.page.evaluate(function() { return window.Teaspoon && window.Teaspoon.finished });
      finished ? this.finish() : setTimeout(this.waitForResults, 200);
    };

    Runner.prototype.fail = function(msg, errno) {
      if (msg == null) msg = null;
      if (errno == null) errno = 1;

      console.log(JSON.stringify({
        _teaspoon: true,
        type: "exception",
        message: msg
      }));
      phantom.exit(errno);
    };

    Runner.prototype.finish = function() {
      phantom.exit(0);
    };

    Runner.prototype.pageCallbacks = function() {
      var _this = this;
      return {
        onError: function(message, trace) {
          var started = _this.page.evaluate(function() {
            return window.Teaspoon && window.Teaspoon.started;
          });
          console.log(JSON.stringify({
            _teaspoon: true,
            type: started ? "error" : "exception",
            message: message,
            trace: trace
          }));
          _this.errored = true;
          if (/^TeaspoonError: /.test(message || "")) {
            _this.fail("Execution halted.");
          }
        },

        onConsoleMessage: function(msg) {
          console.log(msg);
          if (_this.errorTimeout) clearTimeout(_this.errorTimeout);
          if (_this.errored) {
            _this.errorTimeout = setTimeout((function() {
              return _this.fail("Javascript error has caused a timeout.");
            }), _this.timeout);
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
            if (status === "success") {
              // Could not load the window.Teaspoon object from the JavaScript on the
              // rendered page. This indicates that a problem occured. Lets therfore
              // print the page as a failure description.
              // Get plain text of the page, intend all lines (better readable)
              var ind = "   ";
              var error = _this.page.plainText.replace(/(?:\n)/g, "\n" + ind);
              // take only first 10 lines, as they usually provide a good entry
              // point for debugging and we should not spam our console.
              var erroroutput = error.split("\n").slice(0, 10);
              if (erroroutput !== error) {
                erroroutput.push("... (further lines have been removed)");
              }
              var fail = [
                "Failed to get Teaspoon result object on page: " + _this.url,
                "The title of this page was '" + _this.page.title + "'.",
                "",
                erroroutput.join("\n")
              ];

              _this.fail(fail.join(" \n" + ind));
            }
            else {
              // Status is not 'success'
              _this.fail("Failed to load: " + _this.url + ". Status: " + status);
              return;
            }
          }
          _this.waitForResults();
        }
      };
    };

    return Runner;

  })();

  new Runner().run();

}).call(this);
