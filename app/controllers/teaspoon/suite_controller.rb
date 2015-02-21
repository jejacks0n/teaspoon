class Teaspoon::SuiteController < ActionController::Base
  before_filter :prepend_fixture_paths

  helper Teaspoon::SpecHelper rescue nil

  layout false

  def index
    @suites = Teaspoon::Suite.all
  end

  def show
    @suite = Teaspoon::Suite.new(params)
  end

  def hook
    hooks = Teaspoon::Suite.new(params).hooks[params[:hook].to_s]
    hooks.each { |hook| hook.call(params[:hook_args]) }
    render nothing: true
  end

  def fixtures
    render template: "/#{params[:filename]}"
  end

  private

  def prepend_fixture_paths
    Teaspoon.configuration.fixture_paths.each do |path|
      prepend_view_path Teaspoon.configuration.root.join(path)
    end
  end
end
