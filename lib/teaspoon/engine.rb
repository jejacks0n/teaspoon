require "teaspoon/environment"
require "teaspoon/suite"
require "teaspoon/instrumentation"

module Teaspoon
  class Engine < ::Rails::Engine
    isolate_namespace Teaspoon

    routes do
      root to: "suite#index"
      match "/fixtures/*filename", to: "suite#fixtures", via: :get, as: "fixture"
      match "/:suite", to: "suite#show", via: :get, as: "suite", defaults: { suite: "default" }
      match "/:suite/:hook", to: "suite#hook", via: :post, defaults: { suite: "default", hook: "default" }
    end

    initializer :assets, group: :all do |app|
      begin
        Teaspoon::Environment.require_environment
      rescue Teaspoon::EnvironmentNotFound
        # it's ok for this to fail sometimes, like before the generator is run etc
      end

      Teaspoon::Engine.default_root_path(app.root)           # default the root if it's not set
      Teaspoon::Engine.append_asset_paths(app.config.assets) # append the asset paths from the configuration
      Teaspoon::Engine.add_precompiled_assets(app.config.assets)
    end

    config.after_initialize do |app|
      Teaspoon::Engine.inject_instrumentation                # inject our sprockets hack for instrumenting javascripts
      Teaspoon::Engine.prepend_routes(app)                   # prepend routes so a catchall doesn't get in the way
    end

    def self.default_root_path(root)
      Teaspoon.configuration.root ||= root
    end

    def self.append_asset_paths(assets)
      Teaspoon.configuration.asset_paths.each do |path|
        assets.paths << Teaspoon.configuration.root.join(path).to_s
      end

      # TODO: This breaks lazy loading of frameworks. Another way to avoid this?
      Teaspoon::Framework.available.keys.each do |framework|
        assets.paths += Teaspoon::Framework.fetch(framework).asset_paths
      end
    end

    def self.add_precompiled_assets(assets)
      assets.precompile += Teaspoon.configuration.asset_manifest
    end

    def self.inject_instrumentation
      Sprockets::Environment.send(:include, Teaspoon::SprocketsInstrumentation)
      Sprockets::Index.send(:include, Teaspoon::SprocketsInstrumentation)
    end

    def self.prepend_routes(app)
      mount_at = Teaspoon.configuration.mount_at

      return if app.routes.recognize_path(mount_at)[:action] != "routing_error" rescue nil
      require Teaspoon::Engine.root.join("app/controllers/teaspoon/suite_controller")

      app.routes.prepend { mount Teaspoon::Engine => mount_at, as: "teaspoon" }
    end

    module ExceptionHandling
      def self.add_rails_handling
        return unless using_phantomjs?

        # debugging should be off to display errors in the suite_controller
        # Rails.application.config.assets.debug = false

        # we want rails to display exceptions
        Rails.application.config.action_dispatch.show_exceptions = true

        # override the render exception method in ActionDispatch to raise a javascript exception
        render_exceptions_with_javascript
      end

      private

      def self.using_phantomjs?
        Teaspoon::Driver.equal?(Teaspoon.configuration.driver, :phantomjs)
      end

      def self.render_exceptions_with_javascript
        ActionDispatch::DebugExceptions.class_eval do
          def render_exception(_env, exception)
            message = "#{exception.class.name}: #{exception.message}"
            body = "<script>throw Error(#{[message, exception.backtrace].join("\n").inspect})</script>"
            [200, { "Content-Type" => "text/html;", "Content-Length" => body.bytesize.to_s }, [body]]
          end
        end
      end
    end
  end
end
