begin
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
rescue LoadError
  puts "Not using codeclimate-test-reporter."
end

ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_ROOT"] = File.expand_path("../dummy", __FILE__)
require File.expand_path("../dummy/config/environment", __FILE__)

require "rspec/rails"
require "capybara/rails"

require "fileutils"
require "ostruct"

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.order = "random"
  config.include Teaspoon::Devkit

  config.before(:each, shell: true) do
    @dirs = [ENV["ARUBA_PATH"]] if ENV["ARUBA_PATH"]
    @aruba_timeout_seconds = 180
    clean_current_dir
  end

  config.after(:each, shell: true) do
    restore_env
  end

  config.before(:each, browser: true) do
    Capybara.current_driver = Capybara.javascript_driver
  end
end
