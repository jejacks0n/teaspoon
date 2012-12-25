Teabag.setup do |config|

  config.root = Teabag::Engine.root
  config.asset_paths << Teabag::Engine.root.join('lib/teabag')

  config.suite do |suite|
    suite.javascripts = ["teabag/jasmine"]
  end

  config.suite :jasmine do |suite|
    suite.matcher = "spec/javascripts/**/*_jspec.{js,js.coffee,coffee}"
    suite.javascripts = ["teabag/jasmine"]
    suite.helper = "jasmine_helper"
  end

  config.suite :mocha do |suite|
    suite.matcher = "spec/javascripts/**/*_mspec.{js,js.coffee,coffee}"
    suite.javascripts = ["teabag/mocha", "expect"]
    suite.helper = "mocha_helper"
  end

  config.suite :qunit do |suite|
    suite.matcher = "test/javascripts/**/*_test.{js,js.coffee,coffee}"
    suite.javascripts = ["teabag/qunit"]
    suite.helper = "qunit_helper"
  end

end if defined?(Teabag) && Teabag.respond_to?(:setup) # let Teabag be undefined outside of development/test/asset groups
