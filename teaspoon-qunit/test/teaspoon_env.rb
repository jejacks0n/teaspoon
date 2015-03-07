Teaspoon.configure do |config|
  path = "teaspoon-qunit/test/javascripts"
  config.asset_paths << Teaspoon::Engine.root.join(path)
  config.suite :qunit do |suite|
    suite.use_framework :qunit
    suite.matcher = "#{path}/**/*_test.{js,js.coffee,coffee}"
    suite.helper = "qunit_helper"
  end
end
