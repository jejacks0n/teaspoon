Teabag.setup do |config|

  # Mounting / Route
  # This determines where the teabag spec path will be mounted. Changing this to /jasmine would allow you to browse to
  # http://localhost:3000/jasmine to run your jasmine specs.
  #
  # default: "/teabag"
  config.mount_at = "/teabag"

  # Root
  # The root path defaults to Rails.root if left nil, but if you're testing an engine using a dummy application it's
  # useful to be able to set this to your engines root.. E.g. Teabag::Engine.root
  #
  # default: nil, which forces defaulting to Rails.root
  config.root = nil

  # Asset paths
  # These paths are appended to the rails assets paths (relative to config.root), and by default is an array that you
  # can replace or add to.
  #
  # default: ["spec/javascripts", "spec/javascripts/stylesheets"]
  config.asset_paths << "app/assets/some_other_path"

  # Fixtures
  # Fixtures are different than the specs, in that Rails is rendering them directly through a controller. This means you
  # can use haml, erb builder, rabl, etc. to render content in the views available in this path.
  #
  # default: "spec/javascripts/fixtures"
  config.fixture_path = "spec/javascripts/fixtures"

  # Server timeout
  # Timeout for starting the server in seconds when running from the console. If your server is slow to start you may
  # have to bump the timeout, or you may want to lower this if you know it shouldn't take long to start.
  #
  # default: 20
  config.server_timeout = 20

  # Failing Fast
  # When you run several suites it can be useful to make Teabag fail directly after the suite with failing examples is
  # finished (not continuing on to the next suite), but in environments like CI this isn't as desirable. You can also
  # configure this using the fail_fast environment variable.
  #
  # default: true
  # Note: override this directive by running `rake teabag fail_fast=false`
  config.fail_fast = true

  # Suppressing Logs
  # When you run Teabag from the console, it will pipe all console.log/debug/etc. calls to the console. This is useful
  # to catch places where you've forgotten to remove console.log calls, but in verbose applications that use logging
  # heavily this may not be desirable.
  #
  # default: false
  # Note: override this directive by running `rake teabag suppress_log=true`
  config.suppress_log = false

  # Suites
  # You can modify the default suite configuration or create new suites here. Suites can be entirely isolated from one
  # another. When defining a suite you can provide a name and a block. If the name is left blank, :default is assumed.
  # When defining suites, you can omit various directives and the defaults will be used.
  #
  # To run a specific suite
  #   - in the browser: http://localhost/teabag/[suite_name]
  #   - from the command line: rake teabag suite=[suite_name]
  config.suite do |suite|

    # File Matcher
    # You can specify a file matcher for your specs, and the matching files will be automatically loaded when the suite
    # is run. It's important that these files are serve-able from sprockets (aka the asset pipeline), otherwise it will
    # reference the full path of the file, which probably work out that well.
    #
    # default: "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"
    # Note: set to nil if you want to load your spec files using a manifest from within the spec helper file.
    suite.matcher = "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"

    # Spec Helper
    # Each suite can load a different spec helper, which can in turn require additional files. Since this file is served
    # via the asset pipeline, you can use the require directive and include whatever else seems useful to you. This file
    # is loaded before your specs are loaded -- so could potentially also include all of your specs (if you set the
    # matcher to nil).
    #
    # default: "spec_helper"
    suite.helper = "spec_helper"

    # Javascripts
    # These are the core teabag javascripts. Spec files should not go here -- but if you want to add additional support
    # for jasmine matchers, switch to mocha, include expectation libraries etc., this is the right place to do it.
    #
    # To use mocha, you should switch this to:
    #   "teabag-mocha"
    #
    # To use the coffeescript source files:
    #   "teabag/jasmine" or "teabag/mocha"
    #
    # default: ["teabag-jasmine"]
    suite.javascripts = ["teabag-jasmine"]

    # Stylesheets
    # If you want to change how teabag looks, or include your own stylesheets you can do that here. The default is the
    # stylesheet for the HTML reporter.
    #
    # default: ["teabag"]
    suite.stylesheets = ["teabag"]
  end

  # Here's an example of creating a named suite.  Since we're actually just filtering specs to files already within the
  # root spec/javascripts, these files will also be run in the default suite -- but can be focused into a more specific
  # suite.
  #
  # To run this suite
  #   - in the browser: http://localhost/teabag/targeted
  #   - from the command line: rake teabag suite=targeted
  #config.suite :targeted do |suite|
  #  suite.matcher = "spec/javascripts/targeted/*_spec.{js,js.coffee,coffee}"
  #end

end if defined?(Teabag) && Teabag.respond_to?(:setup) # let Teabag be undefined outside of development/test/asset groups
