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

    cattr_accessor   :mount_at, :root, :asset_paths, :fixture_paths
    @@mount_at       = "/teaspoon"
    @@root           = nil # will default to Rails.root
    @@asset_paths    = ["spec/javascripts", "spec/javascripts/stylesheets", "test/javascripts", "test/javascripts/stylesheets"]
    @@fixture_paths  = ["spec/javascripts/fixtures", "test/javascripts/fixtures"]

    # console runner specific

    cattr_accessor   :driver, :driver_options, :driver_timeout, :server, :server_port, :server_timeout, :fail_fast,
                     :formatters, :color, :suppress_log,
                     :use_coverage
    @@driver         = "phantomjs"
    @@driver_options = nil
    @@driver_timeout = 180
    @@server         = nil
    @@server_port    = nil
    @@server_timeout = 20
    @@fail_fast      = true

    @@formatters     = ["dot"]
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
    @@suite_configs = {"default" => {block: proc{}}}

    def self.suite(name = :default, &block)
      @@suite_configs[name.to_s] = {block: block, instance: Suite.new(&block)}
    end

    class Suite

      FRAMEWORKS = {
        jasmine: ["1.3.1", "2.0.0"],
        mocha: ["1.10.0", "1.17.1"],
        qunit: ["1.12.0", "1.14.0"],
        angular: ["1.0.5"],
      }

      attr_accessor   :matcher, :helper, :javascripts, :stylesheets,
                      :boot_partial, :body_partial,
                      :no_coverage,
                      :hooks

      def initialize
        @matcher      = "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"
        @helper       = "spec_helper"
        @javascripts  = ["jasmine/1.3.1", "teaspoon-jasmine"]
        @stylesheets  = ["teaspoon"]

        @boot_partial = "boot"
        @body_partial = "body"

        @no_coverage  = [%r{/lib/ruby/gems/}, %r{/vendor/assets/}, %r{/support/}, %r{/(.+)_helper.}]

        @hooks        = Hash.new{ |h, k| h[k] = [] }

        default = Teaspoon.configuration.suite_configs["default"]
        self.instance_eval(&default[:block]) if default
        yield self if block_given?
      end

      def use_framework(name, version = nil)
        name = name.to_sym
        version ||= FRAMEWORKS[name].last if FRAMEWORKS[name]
        unless FRAMEWORKS[name] && FRAMEWORKS[name].include?(version)
          message = "Unknown framework \"#{name}\""
          message += " with version #{version} -- available versions #{FRAMEWORKS[name].join(", ")}" if FRAMEWORKS[name] && version
          raise Teaspoon::UnknownFramework, message
        end

        @javascripts = [[name, version].join("/"), "teaspoon-#{name}"]
        case name.to_sym
        when :qunit
          @matcher = "{test/javascripts,app/assets}/**/*_test.{js,js.coffee,coffee}"
          @helper  = "test_helper"
        else
        end
      end
      alias_method :use_framework=, :use_framework

      def hook(group = :default, &block)
        @hooks[group.to_s] << block
      end
    end

    # coverage configurations

    cattr_accessor :coverage_configs
    @@coverage_configs = {"default" => {block: proc{}}}

    def self.coverage(name = :default, &block)
      @@coverage_configs[name.to_s] = {block: block, instance: Coverage.new(&block)}
    end

    class Coverage
      attr_accessor   :reports, :output_path,
                      :statements, :functions, :branches, :lines

      def initialize
        @reports      = ["text-summary"]
        @output_path  = "coverage"

        @statements   = nil
        @functions    = nil
        @branches     = nil
        @lines        = nil

        default = Teaspoon.configuration.coverage_configs["default"]
        self.instance_eval(&default[:block]) if default
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
