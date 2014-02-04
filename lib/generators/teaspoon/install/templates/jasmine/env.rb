# Set RAILS_ROOT and load the environment if it's not already loaded.
unless defined?(Rails)
  ENV["RAILS_ROOT"] = File.expand_path("../../", __FILE__)
  require File.expand_path("../../config/environment", __FILE__)
end

Teaspoon.setup do |config|

  # This determines where the Teaspoon routes will be mounted. Changing this to "/jasmine" would allow you to browse to
  # http://localhost:3000/jasmine to run your specs.
  #config.mount_at = "/teaspoon"

  # This defaults to Rails.root if left nil. If you're testing an engine using a dummy application it can be useful to
  # set this to your engines root.. E.g. `Teaspoon::Engine.root`
  #config.root = nil

  # These paths are appended to the Rails assets paths (relative to config.root), and by default is an array that you
  # can replace or add to.
  #config.asset_paths = ["spec/javascripts", "spec/javascripts/stylesheets"]

  # Fixtures are rendered through a standard controller. This means you can use things like HAML or RABL/JBuilder, etc.
  # to generate fixtures within this path.
  #config.fixture_path = "spec/javascripts/fixtures"

  # You can modify the default suite configuration and create new suites here. Suites can be isolated from one another.
  # When defining a suite you can provide a name and a block. If the name is left blank, :default is assumed. You can
  # omit various directives and the defaults will be used.
  #
  # To run a specific suite
  # - in the browser: http://localhost/teaspoon/[suite_name]
  # - with the rake task: rake teaspoon suite=[suite_name]
  # - with the cli: teaspoon --suite=[suite_name]
  config.suite do |suite|

    # You can specify a file matcher and all matching files will be loaded when the suite is run. It's important that
    # these paths and files are serve-able from sprockets.
    #suite.matcher = "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"

    # Each suite can load a different helper, which can in turn require additional files. This file is loaded before
    # your specs are loaded, and can be used as a manifest.
    #suite.helper = "spec_helper"

    # These are the core Teaspoon javascripts. It's strongly encouraged to include only the base files here. You can
    # require other support libraries in your spec helper, which allows you to change them without having to restart the
    # server.
    #
    # Available frameworks: teaspoon-jasmine, teaspoon-mocha, teaspoon-qunit
    #
    # Note: To use the CoffeeScript source files use "teaspoon/jasmine" etc.
    suite.javascripts = ["teaspoon-jasmine"]

    # If you want to change how Teaspoon looks, or include your own stylesheets you can do that here. The default is the
    # stylesheet used for the HTML reporter.
    #suite.stylesheets = ["teaspoon"]

  end

  # Example suite. Since we're just filtering to files already within the root spec/javascripts, these files will also
  # be run in the default suite -- but can be focused into a more specific suite.
  #config.suite :targeted do |suite|
  #  suite.matcher = "spec/javascripts/targeted/*_spec.{js,js.coffee,coffee}"
  #end

  # CONSOLE RUNNER SPECIFIC
  #
  # These configuration settings only apply when running from the command line. These options can be overridden using
  # the command line interface arguments, or with ENV variables using the rake task.
  #
  # Command Line Interface (CLI):
  # teaspoon --driver=phantomjs --server-port=31337 --fail-fast=true --format=junit --suite=my_suite /spec/file_spec.js
  #
  # Rake:
  # teaspoon DRIVER=phantomjs SERVER_PORT=31337 FAIL_FAST=true FORMATTERS=junit suite=my_suite

  # Allows you to specify which driver to use when running headlessly. Supports PhantomJS and Selenium Webdriver.
  #
  # Available drivers: phantomjs (default), selenium
  #config.driver = "phantomjs"

  # Specify additional options/switches to the driver. Currently this is only supported if using the PhantomJS driver.
  # e.g. "--ssl-protocol=any --ssl-certificates-path=/path/to/certs"
  #config.driver_options = nil

  # Allows specifying the timeout used by the drivers. Specs are expected to complete within this timeframe or the
  # drivers will fail. This is to avoid issues that can arise where the tests stall.
  #config.driver_timeout = 180

  # Specify a server to use with Rack (eg. thin, mongrel). If nil is provided Rack::Server is used.
  #config.server = nil

  # By default Teaspoon will locate an open port when starting the server, but if you want to run on a specific port
  # you can do so by providing one.
  #config.server_port = nil

  # Timeout for starting the server in seconds. If your server is slow to start you may have to bump this, or you may
  # want to lower this if you know it shouldn't take long to start.
  #config.server_timeout = 20

  # If you have several suites it can be useful to make Teaspoon fail directly after any suite contains failures, but in
  # environments like CI this may not be desirable.
  #config.fail_fast = true

  # You can specify the formatters that Teaspoon will use when outputting the results.
  #
  # Available formatters: dot (default), clean, json, junit, pride, snowday, swayze_or_oprah, tap, tap_y, teamcity
  #config.formatters = "dot"

  # Teaspoon pipes all console[log/debug/error] to STDOUT. This is useful to catch places where you've forgotten to
  # remove them, but in verbose applications this may not be desirable.
  #config.suppress_log = false

  # Specify if you want color output from the formatters.
  #config.color = true

  # COVERAGE REPORTS / THRESHOLD ASSERTIONS
  #
  # Coverage reports requires istanbul (https://github.com/gotwarlost/istanbul). Add instrumentation to your code and
  # display coverage statistics.
  #
  # Coverage configurations are similar to suites. You can define several, and use different ones under different
  # conditions.
  #
  #config.coverage do |coverage|
  #  coverage.reports = "text,html,cobertura"
  #  coverage.output_dir = "coverage"
  #  coverage.statement_threshold = 50
  #  coverage.function_threshold = 50
  #  coverage.branch_threshold = 50
  #  coverage.line_threshold = 50
  #end

end
