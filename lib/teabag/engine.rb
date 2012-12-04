class Teabag::Engine < ::Rails::Engine

  isolate_namespace Teabag

  initializer :assets, :group => :all do |app|
    Teabag.configuration.root ||= app.root
    Teabag.configuration.asset_paths.each do |path|
      app.config.assets.paths << Teabag.configuration.root.join(path).to_s
    end
  end
end
