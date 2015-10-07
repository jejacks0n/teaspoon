begin
  require "codeclimate-test-reporter"
  require "simplecov"
  # SimpleCov.profiles.define "teaspoon" do
  #   filters.clear
  #   add_filter { |src| !(src.filename =~ /^#{SimpleCov.root}/) unless src.filename =~ /teaspoon/ }
  #   # filter the framework implementations
  #   add_filter("lib/teaspoon-(jasmine|mocha|qunit).rb")
  #   # filter deprecation warnings, devkit tools, and our teaspoon envs
  #   add_filter("teaspoon/deprecated.rb")
  #   add_filter("devkit.rb")
  #   add_filter("teaspoon_env.rb")
  #   # filter the controller, since it's tested elsewhere
  #   add_filter("suite_controller.rb")
  # end
  # CodeClimate::TestReporter.configuration.profile = "teaspoon"
  CodeClimate::TestReporter.configure do |config|
    config.path_prefix = File.expand_path('../../', __FILE__)
  end
  CodeClimate::TestReporter.start
rescue LoadError
  puts "Not using codeclimate-test-reporter."
end

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
