# Set RAILS_ROOT and load the environment if it's not already loaded.
unless defined?(Rails)
  ENV["RAILS_ROOT"] = File.expand_path("../dummy", __FILE__)
  require File.expand_path("../dummy/config/environment", __FILE__)
end

Teaspoon.configure do |config|
  config.root = Teaspoon::Engine.root
  config.asset_paths << Teaspoon::Engine.root.join("lib/teaspoon")

  config.suite do |suite|
    roots = "spec/javascripts,spec/dummy/app/assets/javascripts/specs"
    suite.matcher = "{#{roots}}/**/*_spec.{js,js.coffee,coffee,js.coffee.erb}"
    suite.javascripts = ["jasmine/1.3.1", "teaspoon/jasmine"]
  end
end
