ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_ROOT"] = File.expand_path("../dummy", __FILE__)
ENV["TEASPOON_RAILS_ENV"] = File.expand_path("../dummy/config/environment.rb", __FILE__)
ENV["TEASPOON_DEVELOPMENT"] = "true"
require File.expand_path("../dummy/config/environment", __FILE__)

require "rspec/rails"
require "capybara/rails"

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
    @aruba_timeout_seconds = 180
    setup_aruba
  end

  config.after(:each, shell: true) do
    restore_env
  end

  config.before(:each, browser: true) do
    Capybara.current_driver = Capybara.javascript_driver
  end
end
