module Teaspoon
  class Engine < ::Rails::Engine

    isolate_namespace Teaspoon

    initializer :assets, :group => :all do |app|
      # default the root if it's not set
      Teaspoon.configuration.root ||= app.root

      # append the asset paths from the configuration
      Teaspoon.configuration.asset_paths.each do |path|
        app.config.assets.paths << Teaspoon.configuration.root.join(path).to_s
      end
    end

    config.after_initialize do |app|
      # inject our sprockets hack for instrumenting javascripts
      Sprockets::Environment.send(:include, Teaspoon::SprocketsInstrumentation)

      # prepend routes so a catchall doesn't get in the way
      app.routes.prepend do
        mount Teaspoon::Engine => Teaspoon.configuration.mount_at
      end
    end
  end
end
