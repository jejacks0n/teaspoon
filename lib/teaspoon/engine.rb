require "teaspoon/environment"
require "teaspoon/suite"
require "teaspoon/instrumentation"

module Teaspoon
  class Engine < ::Rails::Engine

    isolate_namespace Teaspoon

    config.assets.precompile += %w{ teaspoon.css teaspoon-teaspoon.js }
    config.assets.precompile += %w{ teaspoon-angular.js teaspoon-jasmine.js teaspoon-mocha.js teaspoon-qunit.js }
    config.assets.precompile += %w{ angular/1.0.5.js }
    config.assets.precompile += %w{ jasmine/1.3.1.js jasmine/2.0.0.js }
    config.assets.precompile += %w{ mocha/1.10.0.js mocha/1.17.1.js }
    config.assets.precompile += %w{ qunit/1.12.0.js qunit/1.14.1.js }
    config.assets.precompile += %w{ support/*.js }

    initializer :assets, group: :all do |app|
      begin
        Teaspoon::Environment.require_environment
      rescue Teaspoon::EnvironmentNotFound
        # it's ok for this to fail sometimes, like before the initializer is run etc
      end

      Teaspoon::Engine.default_root_path(app.root)           # default the root if it's not set
      Teaspoon::Engine.append_asset_paths(app.config.assets) # append the asset paths from the configuration
    end

    config.after_initialize do |app|
      Teaspoon::Engine.inject_instrumentation                # inject our sprockets hack for instrumenting javascripts
      Teaspoon::Engine.prepend_routes(app)                   # prepend routes so a catchall doesn't get in the way
    end

    private

    def self.default_root_path(root)
      Teaspoon.configuration.root ||= root
    end

    def self.append_asset_paths(assets)
      Teaspoon.configuration.asset_paths.each do |path|
        assets.paths << Teaspoon.configuration.root.join(path).to_s
      end
    end

    def self.inject_instrumentation
      Sprockets::Environment.send(:include, Teaspoon::SprocketsInstrumentation)
      Sprockets::Index.send(:include, Teaspoon::SprocketsInstrumentation)
    end

    def self.prepend_routes(app)
      mount_at = Teaspoon.configuration.mount_at

      return if app.routes.recognize_path(mount_at)[:action] != 'routing_error' rescue nil
      require Teaspoon::Engine.root.join("app/controllers/teaspoon/suite_controller")

      app.routes.prepend do
        mount Teaspoon::Engine => mount_at, as: "teaspoon"
      end
    end
  end
end
