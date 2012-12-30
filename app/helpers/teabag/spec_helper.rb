module Teabag::SpecHelper

  def javascript_include_tag_for_teabag(*sources)
    sources.collect do |source|
      asset = asset_paths.asset_for(source, "js")
      asset.to_a.map do |dep|
        javascript_include_tag(dep.pathname.to_s, src: path_to_asset(dep, ext: "js", body: true), debug: false)
      end
    end.flatten.uniq.join("\n").html_safe
  end
end
