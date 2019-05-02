require "simplecov"
SimpleCov.start do
  command_name ENV["SIMPLECOV_COMMAND_NAME"] || "teaspoon"

  filters.clear

  add_filter { |src| !(src.filename =~ /teaspoon\//) }
  add_filter [
    "gemfiles", # appraisal installs gems here
    "teaspoon_env.rb", # teaspoon envs
    "devkit.rb", # devkit tools
    "framework.rb", # framework definitions
    "deprecated.rb", # deprecation warnings
    "support/capybara", # spec support
    "suite_controller.rb" # controller, tested in framework implementations
  ]
end unless ENV["SIMPLECOV_COMMAND_NAME"]

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
  config.order = "random:54249"
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
