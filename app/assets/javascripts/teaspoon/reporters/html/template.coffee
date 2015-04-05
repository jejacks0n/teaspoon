Teaspoon.Reporters.HTML.template = -> """
<div class="teaspoon-clearfix">
  <div id="teaspoon-title">
    <h1><a href="#{Teaspoon.root}" id="teaspoon-root-link">Teaspoon</a></h1>
    <ul>
      <li>version: <b id="teaspoon-version"></b></li>
      <li id="teaspoon-env-info"></li>
    </ul>
  </div>
  <div id="teaspoon-progress"></div>
  <ul id="teaspoon-stats">
    <li>passes: <b id="teaspoon-stats-passes">0</b></li>
    <li>failures: <b id="teaspoon-stats-failures">0</b></li>
    <li>skipped: <b id="teaspoon-stats-skipped">0</b></li>
    <li>duration: <b id="teaspoon-stats-duration">&infin;</b></li>
  </ul>
</div>

<div id="teaspoon-controls" class="teaspoon-clearfix">
  <div id="teaspoon-toggles">
    <button id="teaspoon-use-catch" title="Toggle using try/catch wrappers when possible">Try/Catch</button>
    <button id="teaspoon-build-full-report" title="Toggle building the full report">Full Report</button>
    <button id="teaspoon-display-progress" title="Toggle displaying progress as tests run">Progress</button>
  </div>
  <div id="teaspoon-suites"></div>
</div>

<hr/>

<div id="teaspoon-filter">
  <h1>Applied Filters [<a href="#{window.location.pathname}" id="teaspoon-filter-clear">remove</a>]</h1>
  <ul id="teaspoon-filter-list"></ul>
</div>

<div id="teaspoon-report">
  <ol id="teaspoon-report-failures"></ol>
  <ol id="teaspoon-report-all"></ol>
</div>
"""
