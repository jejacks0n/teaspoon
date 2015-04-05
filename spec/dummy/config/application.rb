require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "sprockets/railtie"
begin
  require "haml-rails"
  require "coffee-rails"
  require "sass-rails"
  require "jquery-rails"
rescue LoadError
  # intentionally do nothing here, let the failure happen later.
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Change our relative root url to show that if relative paths are setup properly, teaspoon will
    # continue to work and load the proper urls.
    config.relative_url_root = "/relative"
    config.assets.prefix = "/relative/assets" # this must be set for any asset paths to be correct!
  end
end
