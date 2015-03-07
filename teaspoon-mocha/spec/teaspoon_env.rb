Teaspoon.configure do |config|
  path = "teaspoon-mocha/spec/javascripts"
  config.asset_paths << Teaspoon::Engine.root.join(path)
  config.suite :mocha do |suite|
    suite.use_framework :mocha
    suite.matcher = "#{path}/**/*_spec.{js,js.coffee,coffee}"
    suite.helper = "mocha_helper"
  end
end
