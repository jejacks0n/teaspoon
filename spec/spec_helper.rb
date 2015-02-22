require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_ROOT"] = File.expand_path("../dummy", __FILE__)
require File.expand_path("../dummy/config/environment", __FILE__)

require "rspec/rails"
require "capybara/rails"
require "aruba/api"

require "ostruct"

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.run_all_when_everything_filtered = true

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end
