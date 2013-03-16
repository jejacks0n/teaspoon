Teabag.setup do |config|

  config.root = Teabag::Engine.root
  config.asset_paths << Teabag::Engine.root.join('lib/teabag')

  config.suite do |suite|
    suite.matcher = "{spec/javascripts,spec/dummy/app/assets/javascripts/specs}/**/*_spec.{js,js.coffee,coffee}"
    suite.javascripts = ["teabag/jasmine"]
  end

  config.suite :jasmine do |suite|
    suite.matcher = "spec/javascripts/**/*_jspec.{js,js.coffee,coffee}"
    suite.javascripts = ["teabag/jasmine"]
    suite.helper = "jasmine_helper"
  end

  config.suite :mocha do |suite|
    suite.matcher = "spec/javascripts/**/*_mspec.{js,js.coffee,coffee}"
    suite.javascripts = ["teabag/mocha"]
    suite.helper = "mocha_helper"
  end

  config.suite :qunit do |suite|
    suite.matcher = "test/javascripts/**/*_test.{js,js.coffee,coffee}"
    suite.javascripts = ["teabag/qunit"]
    suite.helper = "qunit_helper"
  end

  config.suite :angular do |suite|
    suite.matcher = "spec/javascripts/**/*_aspec.{js,js.coffee,coffee}"
    suite.javascripts = ["teabag/angular"]
    suite.helper = "angular_helper"
  end

  #config.suite :integration do |suite|
  #  suite.matcher = "spec/dummy/app/assets/javascripts/integration/*_spec.{js,js.coffee,coffee}"
  #  suite.javascripts = ["teabag/jasmine"]
  #  suite.helper = nil
  #end

end if defined?(Teabag) && Teabag.respond_to?(:setup) # let Teabag be undefined outside of development/test/asset groups
