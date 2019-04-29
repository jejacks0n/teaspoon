require "simplecov"
SimpleCov.start do
  filters.clear
  add_filter { |src| !(src.filename =~ /^#{SimpleCov.root}/) unless src.filename =~ /teaspoon/ }
  # filter the framework implementations
  add_filter "teaspoon-(jasmine|mocha|qunit)/**/framework.rb"
  # filter deprecation warnings, devkit tools, and our teaspoon envs
  add_filter "teaspoon/deprecated.rb"
  add_filter "devkit.rb"
  add_filter "teaspoon_env.rb"
  # filter the controller, since it's tested elsewhere
  add_filter "suite_controller.rb"
end

ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_ROOT"] = File.expand_path("../dummy", __FILE__)
ENV["TEASPOON_RAILS_ENV"] = File.expand_path("../dummy/config/environment.rb", __FILE__)
ENV["TEASPOON_DEVELOPMENT"] = "true"
require File.expand_path("../dummy/config/environment", __FILE__)

require "rspec/rails"
require "capybara/rails"
require "aruba/rspec"

require "fileutils"
require "ostruct"

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.order = "random"
  config.color = true
  config.include Teaspoon::Devkit
  config.include Teaspoon::Helpers
  config.include ExitCodes
  config.include LoadableFiles
  config.include Rack::Test::Methods

  config.before(:each, shell: true) do
    @dirs = [ENV["ARUBA_PATH"]] if ENV["ARUBA_PATH"]
    setup_aruba
  end

  config.before(:each, browser: true) do
    Capybara.current_driver = Capybara.javascript_driver = ENV.fetch("CAPYBARA_DRIVER", "chrome_headless").to_sym
  end
end
