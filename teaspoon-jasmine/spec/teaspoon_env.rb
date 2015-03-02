Teaspoon.configure do |config|
  path = "teaspoon-jasmine/spec/javascripts"
  config.asset_paths << Teaspoon::Engine.root.join(path)
  config.suite :jasmine do |suite|
    suite.use_framework :jasmine, "1.3.1"
    suite.matcher = "#{path}/**/*_spec.{js,js.coffee,coffee}"
    suite.helper = "jasmine_helper"
    # suite.body_partial = "/body"
  end

  config.suite :jasmine2 do |suite|
    suite.use_framework :jasmine, "2.2.0"
    suite.matcher = "spec/javascripts/**/*_j2spec.{js,js.coffee,coffee}"
    suite.helper = "jasmine2_helper"
  end

end
