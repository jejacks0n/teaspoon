class Teaspoon::SuiteController < ActionController::Base
  def self.before(*args)
    respond_to?(:before_action) ? before_action(*args) : before_filter(*args)
  end

  before :check_env
  before :prepend_fixture_paths

  layout false

  def index
    @suites = Teaspoon::Suite.all
  end

  def show
    @suite = Teaspoon::Suite.new(params)
  end

  def js
    jstype = params.extract!(:jstype).fetch(:jstype, 'vanilla')
    @suite = Teaspoon::Suite.new(params)
    render "teaspoon/suite/#{jstype}", :content_type => 'application/javascript'
  end

  def hook
    hooks = Teaspoon::Suite.new(params).hooks[params[:hook].to_s]

    if hooks.present?
      hooks.each { |hook| hook.call(hook_params(params[:args])) }
      head(:ok)
    else
      render status: :not_found, json: { err: "The `#{params[:hook]}` hook is not defined in the `#{params[:suite]}` suite " }
    end
  end

  def fixtures
    render template: "/#{params[:filename]}"
  end

  private

    def check_env
      Teaspoon::Environment.check_env!
    end

    def prepend_fixture_paths
      Teaspoon.configuration.fixture_paths.each do |path|
        prepend_view_path Teaspoon.configuration.root.join(path)
      end
    end

    def hook_params(params)
      return params.permit!.to_h if params.respond_to?(:permit!)
      params
    end
end
