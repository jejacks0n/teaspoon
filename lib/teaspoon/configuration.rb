require "singleton"

module Teaspoon

  autoload :Formatters, "teaspoon/formatters/base"
  autoload :Drivers,    "teaspoon/drivers/base"

  class Configuration
    include Singleton

    # CONTRIBUTORS:
    # If you add a configuration option you should do the following before it will be considered for merging.
    # - think about if it should be a suite, coverage, or global configuration
    # - write specs for it, and add it to existing specs in spec/teaspoon/configuration_spec.rb
    # - add it to the readme so it's documented
    # - add it to the command_line.rb if appropriate (_only_ if it's appropriate)
    # - add it to ENV_OVERRIDES if it can be overridden from ENV
    # - add it to the initializers in /lib/generators/install/templates so it's documented there as well

    cattr_accessor :mount_at, :context, :root, :asset_paths, :fixture_path
    @@mount_at       = "/teaspoon"
    @@root           = nil # will default to Rails.root
    @@asset_paths    = ["spec/javascripts", "spec/javascripts/stylesheets", "test/javascripts", "test/javascripts/stylesheets"]
    @@fixture_path   = "spec/javascripts/fixtures"

    # console runner specific
    cattr_accessor :driver, :driver_options, :driver_timeout, :server, :server_port, :server_timeout, :formatters, :fail_fast, :suppress_log, :color
    @@driver         = "phantomjs"
    @@driver_options = nil
    @@driver_timeout = 180
    @@server         = nil
    @@server_port    = nil
    @@server_timeout = 20
    @@formatters     = "dot"
    @@fail_fast      = true
    @@suppress_log   = false
    @@color          = true

    # options that can be specified in the ENV
    ENV_OVERRIDES = {
      boolean: %w(FAIL_FAST SUPPRESS_LOG COLOR),
      integer: %w(DRIVER_TIMEOUT SERVER_TIMEOUT),
      string:  %w(DRIVER DRIVER_OPTIONS SERVER SERVER_PORT FORMATTERS)
    }

    # suite configurations

    cattr_accessor :suite_configs
    @@suite_configs = {"default" => proc{}}

    def self.suite(name = :default, &block)
      @@suite_configs[name.to_s] = block
    end

    class Suite
      attr_accessor :matcher, :helper, :stylesheets, :javascripts, :no_coverage, :boot_partial, :js_config, :hooks, :normalize_asset_path

      def initialize
        @matcher      = "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"
        @helper       = "spec_helper"
        @javascripts  = ["teaspoon-jasmine"]
        @stylesheets  = ["teaspoon"]

        # todo: cleanup
        @boot_partial = nil
        @js_config    = {}
        @hooks        = Hash.new {|h, k| h[k] = [] }

        default = Teaspoon.configuration.suite_configs["default"]
        self.instance_eval(&default) if default
        yield self if block_given?
      end

      # todo: document this.
      def hook(group = :default, &block)
        @hooks[group.to_s] << block
      end

      def normalize_asset_path(filename)
        @normalize_asset_path.call(filename)
      end
    end

    # coverage configurations

    cattr_accessor :coverage_configs
    @@coverage_configs = {"default" => proc{}}

    def self.coverage(name = :default, &block)
      @@coverage_configs[name.to_s] = block
    end

    class Coverage
      attr_accessor :reports, :ignored, :output_path, :statement_threshold, :function_threshold, :branch_threshold, :line_threshold

      def initialize
        @reports             = ["text-summary"]
        @ignored             = [%r{/lib/ruby/gems/}, %r{/vendor/assets/}, %r{/support/}, %r{/(.+)_helper.}]
        @output_path         = "coverage"
        @statement_threshold = nil
        @function_threshold  = nil
        @branch_threshold    = nil
        @line_threshold      = nil

        default = Teaspoon.configuration.coverage_configs["default"]
        self.instance_eval(&default) if default
        yield self if block_given?
      end
    end

    # custom getters / setters

    def self.root=(path)
      @@root = Pathname.new(path.to_s) if path.present?
    end

    def self.formatters
      return ["dot"] if @@formatters.blank?
      return @@formatters if @@formatters.is_a?(Array)
      @@formatters.to_s.split(/,\s?/)
    end

    # override from env or options

    def self.override_from_options(options)
      options.each { |k, v| override(k, v) }
    end

    def self.override_from_env(env)
      ENV_OVERRIDES[:boolean].each { |o| override(o, env[o] == "true") if env[o].present? }
      ENV_OVERRIDES[:integer].each { |o| override(o, env[o].to_i) if env[o].present? }
      ENV_OVERRIDES[:string].each  { |o| override(o, env[o]) if env[o].present? }
    end

    def self.override(config, value)
      setter = "#{config.to_s.downcase}="
      send(setter, value) if respond_to?(setter)
    end
  end

  mattr_accessor :configuration
  @@configuration = Configuration

  def self.setup
    yield @@configuration
    @@configuration.override_from_env(ENV)
  end
end
