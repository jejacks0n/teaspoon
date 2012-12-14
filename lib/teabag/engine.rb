module Teabag
  class Engine < ::Rails::Engine

    isolate_namespace Teabag

    initializer :assets, :group => :all do |app|
      # default the root if it's not set
      Teabag.configuration.root ||= app.root

      # append the asset paths from the configuration
      Teabag.configuration.asset_paths.each do |path|
        app.config.assets.paths << Teabag.configuration.root.join(path).to_s
      end
    end
  end
end
