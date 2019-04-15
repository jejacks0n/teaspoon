require File.expand_path("../boot", __FILE__)

# require "rails"
# Pick the frameworks you want:
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"
begin
  require "coffee-rails"
  require "jquery-rails"
rescue LoadError
  # intentionally do nothing here, let the failure happen later.
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ENV["TEASPOON_ENV"] ||= File.expand_path("../../../../spec/teaspoon_env.rb", __FILE__)

module Dummy
  class Application < Rails::Application
    config.eager_load = false
    config.assets.enabled = true
    config.secret_key_base = "d3375037082cacbd4bb3072b780cbb27"

    # Change our relative root url to show that if relative paths are setup properly, teaspoon will
    # continue to work and load the proper urls.
    config.relative_url_root = "/relative"
    config.assets.prefix = "/relative/assets" # this must be set for any asset paths to be correct!
    config.assets.precompile += %w[teaspoon/*.js foo.js]
  end
end
