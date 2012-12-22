Teabag.setup do |config|

  # This determines where the Teabag spec path will be mounted. Changing this to `"/jasmine"` would allow you to browse
  # to `http://localhost:3000/jasmine` to run your specs.
  config.mount_at = "/teabag"

  # The root path defaults to Rails.root if left nil, but if you're testing an engine using a dummy application it's
  # useful to be able to set this to your engines root.. E.g. `Teabag::Engine.root`
  config.root = nil

  # These paths are appended to the rails assets paths (relative to config.root), and by default is an array that you
  # can replace or add to.
  config.asset_paths = ["spec/javascripts", "spec/javascripts/stylesheets"]

  # Fixtures are different than the specs, in that Rails is rendering them directly through a controller. This means you
  # can use haml, erb builder, rabl, etc. to render content in the views available in this path.
  config.fixture_path = "spec/javascripts/fixtures"

  # You can modify the default suite configuration or create new suites here. Suites can be entirely isolated from one
  # another. When defining a suite you can provide a name and a block. If the name is left blank, :default is assumed.
  # When defining suites, you can omit various directives and the defaults will be used.
  #
  # To run a specific suite
  #   - in the browser: http://localhost/teabag/[suite_name]
  #   - from the command line: rake teabag suite=[suite_name]
  config.suite do |suite|

    # You can specify a file matcher for your specs and the matching files will be automatically loaded when the suite
    # is run. It's important that these files are serve-able from sprockets (aka the asset pipeline).
    #
    # Note: set to nil if you want to load your spec files using a manifest from within the spec helper file.
    suite.matcher = "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"

    # Each suite can load a different spec helper, which can in turn require additional files since this file is also
    # served via the asset pipeline. This file is loaded before your specs are loaded -- so could potentially include
    # all of your specs (if you set the matcher to nil).
    suite.helper = "spec_helper"

    # These are the core Teabag javascripts. Spec files should not go here -- but if you want to add additional support
    # for jasmine matchers, switch to mocha, include expectation libraries etc., this is a good place to do that.
    #
    # To use mocha:
    #   "teabag-mocha"
    #
    # To use the coffeescript source files:
    #   "teabag/jasmine" or "teabag/mocha"
    suite.javascripts = ["teabag-jasmine"]

    # If you want to change how Teabag looks, or include your own stylesheets you can do that here. The default is the
    # stylesheet for the HTML reporter.
    suite.stylesheets = ["teabag"]
  end

  # Example suite. Since we're actually just filtering specs to files already within the root spec/javascripts, these
  # files will also be run in the default suite -- but can be focused into a more specific suite.
  #config.suite :targeted do |suite|
  #  suite.matcher = "spec/javascripts/targeted/*_spec.{js,js.coffee,coffee}"
  #end

  # When Teabag is run from the command line these configuration directives apply.
  #config.formatters = "dot"
  #config.server_timeout = 20
  #config.fail_fast = true
  #config.suppress_log = false

end if defined?(Teabag) && Teabag.respond_to?(:setup) # let Teabag be undefined outside of development/test/asset groups
