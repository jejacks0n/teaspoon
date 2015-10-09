require "teaspoon-devkit"
Teaspoon.require_dummy!

Teaspoon.configure do |config|
  config.asset_paths << path = File.expand_path("../javascripts", __FILE__)
  config.fixture_paths << Teaspoon::FIXTURE_PATH

  config.suite do |suite|
    suite.use_framework :jasmine, "1.3.1"
    suite.matcher = "#{path}/jasmine1/**/*_spec.{js,js.coffee,coffee}"
    suite.helper = "jasmine1_helper"
  end

  config.suite :jasmine2 do |suite|
    suite.use_framework :jasmine, "2.3.4"
    suite.matcher = "#{path}/jasmine2/**/*_spec.{js,js.coffee,coffee}"
    suite.helper = "jasmine2_helper"
  end
end
