Teabag.Reporters.HTML.template = """
<div class="teabag-clearfix">
  <div id="teabag-title">
    <h1>Teabag</h1>
    <ul>
      <li>version: <b id="teabag-version"></b></li>
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
    <button id="teabag-use-catch" title="Toggle using try/catch wrappers when possible">Try/Catch</button>
    <button id="teabag-build-full-report" title="Toggle building the full report">Full Report</button>
    <button id="teabag-display-progress" title="Toggle displaying progress as tests run">Progress</button>
  </div>
  <div id="teabag-suites"></div>
</div>

<hr/>

<div id="teabag-filter">
  <h1>Filtering</h1>
  <ul id="teabag-filter-list"></ul>
</div>

<div id="teabag-report">
  <ol id="teabag-report-failures"></ol>
  <ol id="teabag-report-all"></ol>
</div>
"""
