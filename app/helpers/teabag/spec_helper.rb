module Teabag::SpecHelper

  def stylesheet_link_tag_for_teabag(*sources)
    sources.collect do |source|
      asset = defined?(lookup_asset_for_path) ? lookup_asset_for_path(source, type: :stylesheet) : asset_paths.asset_for(source, "css")
      asset.to_a.map do |dep|
        stylesheet_link_tag(dep.pathname.to_s, href: "/assets/#{dep.logical_path}?body=1", type: "text/css")
      end
    end.flatten.uniq.join("\n").html_safe
  end

  def javascript_include_tag_for_teabag(*sources)
    sources.collect do |source|
      asset = defined?(lookup_asset_for_path) ? lookup_asset_for_path(source, type: :javascript) : asset_paths.asset_for(source, "js")
      asset.to_a.map do |dep|
        javascript_include_tag(dep.pathname.to_s, src: "/assets/#{dep.logical_path}?body=1", type: "text/javascript")
      end
    end.flatten.uniq.join("\n").html_safe
  end
end
