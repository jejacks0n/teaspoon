module Teaspoon::SpecHelper

  def javascript_include_tag_for_teaspoon(*sources)
    options = sources.extract_options!

    sources.collect do |source|
      defined?(lookup_asset_for_path) ? lookup_asset_for_path(source, type: :javascript) : asset_paths.asset_for(source, "js")
    end

    @suite.require_js_asset_tree(sources).collect do |asset|
      javascript_include_tag(asset, type: "text/javascript").split("\n")
    end.join("\n").html_safe
  end
end