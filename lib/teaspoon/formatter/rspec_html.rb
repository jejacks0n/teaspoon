require "erb"
require "teaspoon/formatter/base"

module Teaspoon
  module Formatter
    class RspecHtml < Base
      def initialize(*args)
        super
        @suite_start_template = template Templates::SUITE_START
        @suite_end_template = template Templates::SUITE_END
        @spec_template = template Templates::SPEC
        @current_suite = []
      end

      def log_runner(result)
        log_template template(Templates::HEADER), result
      end

      def log_suite(result)
        while !@current_suite.empty? && @current_suite.size > result.level
          log_suite_end
        end

        log_suite_start result
      end

      def log_spec(result)
        log_template @spec_template, result
      end

      def log_result(result)
        while !@current_suite.empty?
          log_suite_end
        end

        log_template template(Templates::FOOTER), result
      end

      private

      def log_suite_start(result)
        @current_suite << result.label
        log_template @suite_start_template, result
      end

      def log_suite_end
        log_template @suite_end_template, @current_suite.pop
      end

      def template(contents)
        Template.new contents
      end

      def log_template(template, object)
        log_str template.render(object)
      end

      class Template
        include ERB::Util

        def initialize(contents)
          @template = contents
        end

        def render(obj)
          @o = obj
          ERB.new(@template).result binding
        end
      end

      module Templates
        CSS = <<-CSS.strip_heredoc
        body {
          margin: 0;
          padding: 0;
          background: #fff;
          font-size: 80%;
        }

        #teaspoon-header {
          background: #65C400;
          color: #fff;
          height: 4em;
        }

        .teaspoon-report h1 {
          margin: 0px 10px 0px 10px;
          padding: 10px;
          font-family: "Lucida Grande", Helvetica, sans-serif;
          font-size: 1.8em;
          position: absolute;
        }

        #label {
          float: left;
        }

        #display-filters {
          float: left;
          padding: 28px 0 0 40%;
          font-family: "Lucida Grande", Helvetica, sans-serif;
        }

        #summary {
          float: right;
          padding: 5px 10px;
          font-family: "Lucida Grande", Helvetica, sans-serif;
          text-align: right;
        }

        #summary p {
          margin: 0 0 0 2px;
        }

        #summary #totals {
          font-size: 1.2em;
        }

        .example_group {
          background: #fff;
        }

        .results > .example_group {
          margin: 0 10px 5px;
        }

        dl {
          font: normal 11px "Lucida Grande", Helvetica, sans-serif;
        }

        .results > .example_group > dl {
          margin: 0;
          padding: 0 0 5px;
        }

        .results > .example_group > dl dl {
          margin-left: 15px;
        }

        dt {
          padding: 3px;
          background: #65C400;
          color: #fff;
          font-weight: bold;
        }

        dd {
          margin: 5px 0 5px 5px;
          padding: 3px 3px 3px 18px;
        }

        dd .duration {
          padding-left: 5px;
          text-align: right;
          right: 0px;
          float: right;
        }

        dd.example.passed {
          border-left: 5px solid #65C400;
          border-bottom: 1px solid #65C400;
          background: #DBFFB4; color: #3D7700;
        }

        dd.example.pending {
          border-left: 5px solid #FAF834;
          border-bottom: 1px solid #FAF834;
          background: #FCFB98; color: #131313;
        }

        dd.example.failed {
          border-left: 5px solid #C20000;
          border-bottom: 1px solid #C20000;
          color: #C20000; background: #FFFBD3;
        }

        dt.pending {
          color: #000000; background: #FAF834;
        }

        dt.failed {
          color: #FFFFFF; background: #C40D0D;
        }

        #teaspoon-header.pending {
          color: #000000; background: #FAF834;
        }

        #teaspoon-header.failed {
          color: #FFFFFF; background: #C40D0D;
        }
        CSS

        JAVASCRIPT = <<-JAVASCRIPT.strip_heredoc
        (function() {
          "use strict";

          if (!document.querySelectorAll) {
            alert("Warning: Your browser does not support document.querySelectorAll. Your report may not work properly.");
            return;
          }

          function get(id) {
            return document.getElementById(id);
          }

          function getAll(scope, selector) {
            if (arguments.length === 1) {
              selector = scope;
              scope = document;
            }

            return scope.querySelectorAll(selector);
          }

          function show(element) {
            if (element.oldDisplayValue) {
              element.style.display = element.oldDisplayValue;
            } else {
              element.style.display = "";
            }
          }

          function hide(element) {
            if (element.style.display === "none") {
              return;
            }

            if (element.oldDisplayValue === undefined) {
              element.oldDisplayValue = element.style.display;
            }

            element.style.display = "none";
          }

          function showAll(elements) {
            for (var i = 0; i < elements.length; i++) {
              show(elements[i]);
            }
          }

          function hideAll(elements) {
            for (var i = 0; i < elements.length; i++) {
              hide(elements[i]);
            }
          }

          function toggleAll(elements, display) {
            if (display) {
              showAll(elements);
            } else {
              hideAll(elements);
            }
          }

          function isHidden(element) {
            return element.style.display === "none";
          }

          function isAllHidden(elements) {
            var allHidden = true;

            for (var i = 0; i < elements.length; i++) {
              if (!isHidden(elements[i])) {
                allHidden = false;
                break;
              }
            }

            return allHidden;
          }

          function setText(element, text) {
            while (element.firstChild !== null) {
              element.removeChild(element.firstChild);
            }

            element.appendChild(document.createTextNode(text));
          }

          function addClass(element, className) {
            element.className += " " + className;
          }

          function addClassAll(elements, className) {
            for (var i = 0; i < elements.length; i++) {
              addClass(elements[i], className);
            }
          }

          function hasClass(element, className) {
            return (" " + element.className + " ").replace(/[\\t\\r\\n\\f]/g, " ").indexOf(" " + className + " ") >= 0;
          }

          function isTag(element, tagName) {
            return element.tagName && element.tagName.toLowerCase() === tagName;
          }

          function parents(elements, predicate) {
            var results = [];

            for (var i = 0; i < elements.length; i++) {
              var parent = elements[i].parentNode;

              while (parent) {
                if (predicate(parent)) {
                  results.push(parent);
                }

                parent = parent.parentNode;
              }
            }

            return results;
          }

          function children(elements, predicate) {
            var results = [];

            for (var i = 0; i < elements.length; i++) {
              if (!elements[i].hasChildNodes()) {
                continue;
              }

              for (var j = 0; j < elements[i].childNodes.length; j++) {
                if (predicate(elements[i].childNodes[j])) {
                  results.push(elements[i].childNodes[j]);
                }
              }
            }

            return results;
          }

          var elements = getAll("input[data-class-filter]");

          function handleClassFilterChange(e) {
            var element = e.target || e.srcElement;
            showAll(getAll(".example_group"));
            toggleAll(getAll(".example." + element.getAttribute("data-type")), element.checked);

            var groups = getAll(".example_group");

            for (var i = 0; i < groups.length; i++) {
              if (isAllHidden(getAll(groups[i], ".example"))) {
                hide(groups[i]);
              }
            }
          }

          for (var i = 0; i < elements.length; i++) {
            elements[i].onchange = handleClassFilterChange;
          }

          get("duration").innerHTML = "Finished in <strong></strong>";
          setText(getAll("#duration strong")[0], get("duration-value").value + " seconds");
          get("totals").innerHTML = '<span class="total-amount"></span> examples, <span class="failure-amount"></span> failures, <span class="pending-amount"></span> pending';
          var failureAmount = getAll(".example.failed").length;
          var pendingAmount = getAll(".example.pending").length;
          setText(getAll("#totals .total-amount")[0], getAll(".example").length);
          setText(getAll("#totals .failure-amount")[0], failureAmount);
          setText(getAll("#totals .pending-amount")[0], pendingAmount);

          if (failureAmount > 0) {
            addClass(get("teaspoon-header"), "failed");
          } else if (pendingAmount > 0) {
            addClass(get("teaspoon-header"), "pending");
          }

          function propagateClass(exampleSelector, groupPredicate, classToAdd) {
            var exampleElements = getAll(exampleSelector);

            var groupElements = parents(exampleElements, function(p) {
              return hasClass(p, "example_group") && groupPredicate(p);
            });

            addClassAll(groupElements, classToAdd);
            var dlChildren = children(groupElements, function(c) { return isTag(c, "dl"); });
            var dtChildren = children(dlChildren, function(c) { return isTag(c, "dt"); });
            addClassAll(dtChildren, classToAdd);
          }

          propagateClass(".example.failed", function() { return true; }, "failed");
          propagateClass(".example.pending", function(p) { return !hasClass(p, "failed"); }, "pending");
          propagateClass(".example", function(p) { return !hasClass(p, "failed") && !hasClass(p, "pending"); }, "passed");
        })();
        JAVASCRIPT

        HEADER = <<-HTML.strip_heredoc
        <!DOCTYPE html>
        <html>
          <head>
            <title>Teaspoon results</title>

            <style type="text/css">
              #{CSS}
            </style>
          </head>

          <body>
            <div class="teaspoon-report">
              <div id="teaspoon-header">
                <div id="label">
                  <h1>Teaspoon Code Examples</h1>
                </div>

                <div id="display-filters">
                  <input id="passed-checkbox" data-class-filter data-type="passed" type="checkbox" checked="checked">
                  <label for="passed-checkbox">Passed</label>
                  <input id="failed-checkbox" data-class-filter data-type="failed" type="checkbox" checked="checked">
                  <label for="failed-checkbox">Failed</label>
                  <input id="pending-checkbox" data-class-filter data-type="pending" type="checkbox" checked="checked">
                  <label for="pending-checkbox">Pending</label>
                </div>

                <div id="summary">
                  <p id="totals">&nbsp;</p>
                  <p id="duration">&nbsp;</p>
                </div>
              </div>

              <div class="results">
        HTML

        SUITE_START = <<-HTML.strip_heredoc
        <div class="example_group">
          <dl>
            <dt><%= h @o.label %></dt>
        HTML

        SPEC = <<-HTML.strip_heredoc
        <dd class="example <%= h @o.status %>">
          <span class="spec-name"><%= h @o.label %></span>
          <span class="duration"><%= h "\#{@o.elapsed}s" if @o.elapsed %></span>

          <% if @o.failing? %>
            <div class="message">
              <pre><%= h @o.trace %></pre>
            </div>
          <% end %>
        </dd>
        HTML

        SUITE_END = <<-HTML.strip_heredoc
          </dl>
        </div>
        HTML

        FOOTER = <<-HTML.strip_heredoc
              </div>
            </div>

            <input type="hidden" id="duration-value" value="<%= h @o.elapsed %>" />

            <script type="text/javascript">
              #{JAVASCRIPT}
            </script>
          </body>
        </html>
        HTML
      end
    end
  end
end
