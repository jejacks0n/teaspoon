require "teaspoon/environment"
require "teaspoon/suite"
require "teaspoon/instrumentation"

module Teaspoon
  class Engine < ::Rails::Engine

    isolate_namespace Teaspoon

    initializer :assets, group: :all do |app|
      begin
        Teaspoon::Environment.require_environment
      rescue Teaspoon::EnvironmentNotFound
        # it's ok for this to fail sometimes, like before the initializer is run etc
      end

      default_root_path(app.root)                 # default the root if it's not set
      append_asset_paths(app.config.assets)       # append the asset paths from the configuration
    end

    config.after_initialize do |app|
      inject_instrumentation                      # inject our sprockets hack for instrumenting javascripts
      prepend_routes(app)                         # prepend routes so a catchall doesn't get in the way
    end

    private

    def default_root_path(root)
      Teaspoon.configuration.root ||= root
    end

    def append_asset_paths(assets)
      Teaspoon.configuration.asset_paths.each do |path|
        assets.paths << Teaspoon.configuration.root.join(path).to_s
      end
    end

    def inject_instrumentation
      Sprockets::Environment.send(:include, Teaspoon::SprocketsInstrumentation)
    end

    def prepend_routes(app)
      require Teaspoon::Engine.root.join("app/controllers/teaspoon/suite_controller")

      app.routes.prepend do
        mount Teaspoon::Engine => Teaspoon.configuration.mount_at, as: "teaspoon"
      end
    end
  end
end
