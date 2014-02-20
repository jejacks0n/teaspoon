require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "sprockets/railtie"

Bundler.require

module Dummy
  class Application < Rails::Application
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Moved from initializers.
    config.session_store :cookie_store, key: '_dummy_session'
    config.secret_token = 'bc510a13d2fb96575782e90e9f2f64afc0ba4e63e5869b6139613686f104d4d3dd92ee696468de5bcbbb74daedb702d3da97554efbc6792abe75091b9df0a2ab'
    config.secret_key_base = 'bc510a13d2fb96575782e90e9f2f64afc0ba4e63e5869b6139613686f104d4d3dd92ee696468de5bcbbb74daedb702d3da97554efbc6792abe75091b9df0a2ab'

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.relative_url_root = "/relative"
    config.assets.prefix = "/relative/assets" # this must be set for any asset paths to be correct!
  end
end
