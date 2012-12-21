module Teabag::SpecHelper
  def javascript_include_tag_for_teabag(*sources)
    options = sources.extract_options!
    debug   = options.key?(:debug)  ? options.delete(:debug)  : debug_assets?
    body    = options.key?(:body)   ? options.delete(:body)   : false
    digest  = options.key?(:digest) ? options.delete(:digest) : digest_assets?

    foo = sources.collect do |source|
      if asset = asset_paths.asset_for(source, 'js')
        asset.to_a.map { |dep|
          javascript_include_tag(dep.pathname.to_s, { :src => path_to_asset(dep, :ext => 'js', :body => true, :digest => digest) }.merge!(options))
        }
      else
        javascript_include_tag(source.to_s, { :src => path_to_asset(source, :ext => 'js', :body => true, :digest => digest) }.merge!(options))
      end
    end
    foo.flatten.uniq.join("\n").html_safe
  end
end
