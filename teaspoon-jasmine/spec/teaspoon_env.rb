Teaspoon.configure do |config|
  path = "teaspoon-jasmine/spec/javascripts"

  config.asset_paths << Teaspoon::Engine.root.join(path)

  config.suite :jasmine1 do |suite|
    suite.use_framework :jasmine, "1.3.1"
    suite.matcher = "#{path}/jasmine1/**/*_spec.{js,js.coffee,coffee}"
    suite.helper = "jasmine1_helper"
  end

  config.suite :jasmine2 do |suite|
    suite.use_framework :jasmine, "2.2.0"
    suite.matcher = "#{path}/jasmine2/**/*_spec.{js,js.coffee,coffee}"
    suite.helper = "jasmine2_helper"
  end

end
