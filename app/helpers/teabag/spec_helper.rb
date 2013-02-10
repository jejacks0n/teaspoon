module Teabag::SpecHelper

  def stylesheet_link_tag_for_teabag(*sources)
    sources.collect do |source|
      asset = defined?(lookup_asset_for_path) ? lookup_asset_for_path(source, type: :stylesheet) : asset_paths.asset_for(source, "css")
      asset.to_a.map do |dep|
        stylesheet_link_tag(dep.pathname.to_s, href: asset_src(dep, source), type: "text/css").split("\n")
      end
    end.flatten.uniq.join("\n").html_safe
  end

  def javascript_include_tag_for_teabag(*sources)
    options = sources.extract_options!
    sources.collect do |source|
      asset = defined?(lookup_asset_for_path) ? lookup_asset_for_path(source, type: :javascript) : asset_paths.asset_for(source, "js")
      asset.to_a.map do |dep|
        javascript_include_tag(dep.pathname.to_s, src: asset_src(dep, source, options[:instrument]), type: "text/javascript").split("\n")
      end
    end.flatten.uniq.join("\n").html_safe
  end

  def asset_src(dep, source, instrument = false)
    params = "?body=1"
    params << "&instrument=1" if instrument && !@suite.include_spec?(dep.pathname.to_s, source)
    "#{Rails.application.config.assets.prefix}/#{dep.logical_path}#{params}"
  end
end
