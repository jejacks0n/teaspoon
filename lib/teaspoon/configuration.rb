require "singleton"
require "teaspoon/driver"
require "teaspoon/formatter"

module Teaspoon
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

    cattr_accessor :mount_at, :root, :asset_paths, :fixture_paths, :asset_manifest
    @@mount_at       = "/teaspoon"
    @@root           = nil # will default to Rails.root
    @@asset_paths    = ["spec/javascripts", "spec/javascripts/stylesheets",
                        "test/javascripts", "test/javascripts/stylesheets"]
    @@fixture_paths  = ["spec/javascripts/fixtures", "test/javascripts/fixtures"]
    @@asset_manifest = ["teaspoon.css", "teaspoon-filterer.js", "teaspoon/*.js", "support/*.js"]

    # console runner specific

    cattr_accessor :driver, :driver_options, :driver_timeout, :server, :server_port, :server_timeout, :fail_fast,
                   :formatters, :color, :suppress_log,
                   :use_coverage
    @@driver         = Teaspoon::Driver.default
    @@driver_options = nil
    @@driver_timeout = 180
    @@server         = nil
    @@server_port    = nil
    @@server_timeout = 20
    @@fail_fast      = true

    @@formatters     = [Teaspoon::Formatter.default]
    @@color          = true
    @@suppress_log   = false

    @@use_coverage   = nil

    # options that can be specified in the ENV

    ENV_OVERRIDES = {
      boolean: %w(FAIL_FAST SUPPRESS_LOG COLOR),
      integer: %w(DRIVER_TIMEOUT SERVER_TIMEOUT),
      string:  %w(DRIVER DRIVER_OPTIONS SERVER SERVER_PORT FORMATTERS USE_COVERAGE)
    }

    # suite configurations

    cattr_accessor :suite_configs
    @@suite_configs = { "default" => { block: proc {} } }

    def self.suite(name = :default, &block)
      @@suite_configs[name.to_s] = { block: block, instance: Suite.new(name, &block) }
    end

    class Suite
      attr_accessor :matcher, :helper, :javascripts, :stylesheets,
                    :boot_partial, :body_partial,
                    :hooks, :expand_assets

      def initialize(name = nil)
        @matcher       = "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"
        @helper        = "spec_helper"
        @javascripts   = []
        @stylesheets   = ["teaspoon"]

        @boot_partial  = "boot"
        @body_partial  = "body"

        @hooks         = Hash.new { |h, k| h[k] = [] }
        @expand_assets = true

        default = Teaspoon.configuration.suite_configs["default"]
        instance_eval(&default[:block]) if default
        if block_given?
          yield self
          raise Teaspoon::UnspecifiedFramework.new(name: name) if @javascripts.length == 0
        end
      end

      def use_framework(name, version = nil)
        framework = Teaspoon::Framework.fetch(name).new(self)
        @javascripts = framework.javascripts_for(version)
        return if @javascripts

        raise Teaspoon::UnknownFrameworkVersion.new(name: name, version: version)
      end
      alias_method :use_framework=, :use_framework

      def hook(group = :default, &block)
        @hooks[group.to_s] << block
      end

      def no_coverage(*)
        Teaspoon.dep("suite.no_coverage has been removed in Teaspoon 1.0. Please use coverage.ignore instead. https://github.com/modeset/teaspoon/blob/master/CHANGELOG.md")
        []
      end
      alias_method :no_coverage=, :no_coverage
    end

    # coverage configurations

    cattr_accessor :coverage_configs
    @@coverage_configs = { "default" => { block: proc {} } }

    def self.coverage(name = :default, &block)
      @@coverage_configs[name.to_s] = { block: block, instance: Coverage.new(&block) }
    end

    class Coverage
      attr_accessor :reports, :output_path, :ignore,
                    :statements, :functions, :branches, :lines

      def initialize
        @reports      = ["text-summary"]
        @output_path  = "coverage"
        @ignore       = [%r{/.rvm/gems/}, %r{/lib/ruby/gems/}, %r{/vendor/assets/}, %r{/support/}, %r{/(.+)_helper.}]

        @statements   = nil
        @functions    = nil
        @branches     = nil
        @lines        = nil

        default = Teaspoon.configuration.coverage_configs["default"]
        instance_eval(&default[:block]) if default
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

  mattr_accessor :configured, :configuration
  @@configured = false
  @@configuration = Configuration

  def self.configure
    yield @@configuration
    @@configured = true
    @@configuration.override_from_env(ENV)
  end
end
