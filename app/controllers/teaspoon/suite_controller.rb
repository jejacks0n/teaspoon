class Teaspoon::SuiteController < ActionController::Base
  helper Teaspoon::SuiteHelper rescue nil

  before_filter :prepend_fixture_paths

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

  private

  def prepend_fixture_paths
    Teaspoon.configuration.fixture_paths.each do |path|
      prepend_view_path Teaspoon.configuration.root.join(path)
    end
  end
end
