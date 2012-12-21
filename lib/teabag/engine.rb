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

      # todo: temporary bug fix for rails including more files that is should -- adds a flatten before uniq.
      module ::Sprockets::Helpers::RailsHelper
        def javascript_include_tag(*sources)
          options = sources.extract_options!
          debug = options.key?(:debug) ? options.delete(:debug) : debug_assets?
          body  = options.key?(:body)  ? options.delete(:body)  : false
          digest  = options.key?(:digest)  ? options.delete(:digest)  : digest_assets?

          sources.collect do |source|
            if debug && asset = asset_paths.asset_for(source, 'js')
              asset.to_a.map { |dep|
                super(dep.pathname.to_s, { :src => path_to_asset(dep, :ext => 'js', :body => true, :digest => digest) }.merge!(options))
              }
            else
              super(source.to_s, { :src => path_to_asset(source, :ext => 'js', :body => body, :digest => digest) }.merge!(options))
            end
          end.flatten.uniq.join("\n").html_safe
        end
      end
    end
  end
end
