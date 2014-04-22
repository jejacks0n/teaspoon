module Teaspoon::SpecHelper

  def stylesheet_link_tag_for_teaspoon(*sources)
    without_assets_runtime_errors do
      sources.collect do |source|
        asset = defined?(lookup_asset_for_path) ? lookup_asset_for_path(source, type: :stylesheet) : asset_paths.asset_for(source, "css")
        if asset.respond_to?(:logical_path)
          asset.to_a.map do |dep|
            stylesheet_link_tag(dep.pathname.to_s, href: asset_src(dep, source), type: "text/css").split("\n")
          end
        else
          stylesheet_link_tag(source) unless source.blank?
        end
      end.flatten.uniq.join("\n").html_safe
    end
  end

  def javascript_include_tag_for_teaspoon(*sources)
    without_assets_runtime_errors do
      options = sources.extract_options!
      sources.collect do |source|
        asset = defined?(lookup_asset_for_path) ? lookup_asset_for_path(source, type: :javascript) : asset_paths.asset_for(source, "js")
        if asset.respond_to?(:logical_path)
          asset.to_a.map do |dep|
            javascript_include_tag(dep.pathname.to_s, src: asset_src(dep, options[:instrument]), type: "text/javascript").split("\n")
          end
        else
          javascript_include_tag(source) unless source.blank?
        end
      end.flatten.uniq.join("\n").html_safe
    end
  end

  def asset_src(dep, instrument = false)
    params = "?body=1"
    params << "&instrument=1" if instrument && @suite && @suite.instrument_file?(dep.pathname.to_s)

    "#{Teaspoon.configuration.context}#{Rails.application.config.assets.prefix}/#{dep.logical_path}#{params}"
  end

  private
  def without_assets_runtime_errors
    previous_value = Sprockets::Rails::Helper.raise_runtime_errors
    Sprockets::Rails::Helper.raise_runtime_errors = false

    yield
  ensure
    Sprockets::Rails::Helper.raise_runtime_errors = previous_value
  end
end
