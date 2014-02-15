class Teaspoon::SuiteController < ActionController::Base
  helper Teaspoon::SuiteHelper rescue nil

  prepend_view_path Teaspoon.configuration.root.join(Teaspoon.configuration.fixture_path)

  layout false

  def index
    @suites = Teaspoon::Suite.all
  end

  def show
    @suite = Teaspoon::Suite.new(params)
  end

  def hook
    Teaspoon::Suite.new(params).hooks[params[:hook].to_s].each { |hook| hook.call }
    render nothing: true
  end

  def fixtures
    render "/#{params[:filename]}"
  end
end
