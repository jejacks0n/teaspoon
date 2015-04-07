Teaspoon.configure do |config|
  config.root = Teaspoon::Engine.root
  config.asset_paths << Teaspoon::Engine.root.join("lib/teaspoon")

  config.suite do |suite|
    roots = "spec/javascripts,spec/dummy/app/assets/javascripts/specs"
    suite.matcher = "{#{roots}}/**/*_spec.{js,js.coffee,coffee,js.coffee.erb}"
    suite.javascripts = ["jasmine/1.3.1", "teaspoon/jasmine1"]
  end
end
