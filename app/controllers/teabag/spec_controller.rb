class Teabag::SpecController < ActionController::Base
  helper Teabag::SpecHelper rescue nil

  layout false

  def index
    @suite = Teabag::Suite.new(params[:suite])
  end

  def fixtures
    prepend_view_path Teabag.configuration.root.join(Teabag.configuration.fixture_path)
    render "/#{params[:filename]}"
  end
end
