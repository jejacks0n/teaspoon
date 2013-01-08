class Teabag::SpecController < ActionController::Base
  helper Teabag::SpecHelper rescue nil

  layout false

  unless Rails.application.config.assets.debug
    rescue_from Teabag::AssetNotServable, with: :javascript_exception
  end

  def index
    @suite = Teabag::Suite.new(params)
  end

  def fixtures
    prepend_view_path Teabag.configuration.root.join(Teabag.configuration.fixture_path)
    render "/#{params[:filename]}"
  end

  private

  def javascript_exception(exception)
    err  = "#{exception.class.name}: #{exception.message}"
    render text: "<script>throw Error(#{err.inspect})</script>"
  end
end
