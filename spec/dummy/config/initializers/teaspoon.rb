Teaspoon.setup do |config|

  config.root = Teaspoon::Engine.root
  config.asset_paths << Teaspoon::Engine.root.join('lib/teaspoon')

  config.suite do |suite|
    suite.matcher = "{spec/javascripts,spec/dummy/app/assets/javascripts/specs}/**/*_spec.{js,js.coffee,coffee}"
    suite.javascripts = ["teaspoon/jasmine"]
  end

  config.suite :jasmine do |suite|
    suite.matcher = "spec/javascripts/**/*_jspec.{js,js.coffee,coffee}"
    suite.javascripts = ["teaspoon/jasmine"]
    suite.helper = "jasmine_helper"
  end

  config.suite :mocha do |suite|
    suite.matcher = "spec/javascripts/**/*_mspec.{js,js.coffee,coffee}"
    suite.javascripts = ["teaspoon/mocha"]
    suite.helper = "mocha_helper"
  end

  config.suite :qunit do |suite|
    suite.matcher = "test/javascripts/**/*_test.{js,js.coffee,coffee}"
    suite.javascripts = ["teaspoon/qunit"]
    suite.helper = "qunit_helper"
  end

  config.suite :angular do |suite|
    suite.matcher = "spec/javascripts/**/*_aspec.{js,js.coffee,coffee}"
    suite.javascripts = ["teaspoon/angular"]
    suite.helper = "angular_helper"
  end

  #config.suite :integration do |suite|
  #  suite.matcher = "spec/dummy/app/assets/javascripts/integration/*_spec.{js,js.coffee,coffee}"
  #  suite.javascripts = ["teaspoon/jasmine"]
  #  suite.helper = nil
  #end

end if defined?(Teaspoon) && Teaspoon.respond_to?(:setup) # let Teaspoon be undefined outside of development/test/asset groups
