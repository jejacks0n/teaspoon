Teabag.setup do |config|

  config.root = Teabag::Engine.root
  config.asset_paths << Teabag::Engine.root.join('lib/teabag')

  config.suite do |suite|
    suite.javascripts = ["teabag/jasmine"]
  end

  config.suite :jasmine do |suite|
    suite.matcher = "spec/javascripts/**/*_jspec.{js,js.coffee,coffee}"
    suite.javascripts = ["teabag/jasmine"]
  end

  config.suite :mocha do |suite|
    suite.matcher = "spec/javascripts/**/*_mspec.{js,js.coffee,coffee}"
    suite.javascripts = ["teabag/mocha", "expect"]
  end

end if defined?(Teabag) && Teabag.respond_to?(:setup) # let Teabag be undefined outside of development/test/asset groups
