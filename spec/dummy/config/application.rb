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

    config.assets.enabled = true

    # Change our relative root url to show that if relative paths are setup properly, teaspoon will
    # continue to work and load the proper urls.
    config.relative_url_root = "/relative"
    config.assets.prefix = "/relative/assets" # this must be set for any asset paths to be correct!

    secret_string = "12077500d55798a739945c97696367c3725ce90463131e1000379143f6732f2bcfaef023db841eea4b370f8599448b7a36d7baa389053d2207150120d0579eaf"
    config.secret_key_base = secret_string
    config.secret_token    = secret_string
  end
end
