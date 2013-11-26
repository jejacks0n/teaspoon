class Teaspoon::SpecController < ActionController::Base
  helper Teaspoon::SpecHelper rescue nil

  layout false

  unless Rails.application.config.assets.debug
    rescue_from Exception, with: :javascript_exception
  end

  def suites
    @suites = Teaspoon::Suite.all
  end

  def runner
    @javascript_options = {}
    @javascript_options[:instrument] = Teaspoon.configuration.coverage || params[:coverage] == "true"
    @suite = Teaspoon::Suite.new(params)
  end

  def hooks
    @suite = Teaspoon::Suite.new(params)
    @suite.run_hooks(params[:group])

    render nothing: true
  end

  def fixtures
    prepend_view_path Teaspoon.configuration.root.join(Teaspoon.configuration.fixture_path)
    render "/#{params[:filename]}"
  end

  private

  def javascript_exception(exception)
    err = "#{exception.class.name}: #{exception.message}"
    render text: "<script>throw Error(#{err.inspect})</script>"
  end
end
