require "teaspoon-devkit"
Teaspoon.require_dummy!

Teaspoon.configure do |config|
  config.asset_paths << path = File.expand_path("../javascripts", __FILE__)
  config.fixture_paths << Teaspoon::FIXTURE_PATH

  config.suite do |suite|
    suite.use_framework :mocha, "2.3.3"
    suite.matcher = "#{path}/**/*_spec.{js,js.coffee,coffee}"
  end
end
