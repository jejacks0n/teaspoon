require "singleton"

module Teaspoon
  class Configuration
    include Singleton

    cattr_accessor :mount_at, :root, :asset_paths, :fixture_path, :suites, :driver_cli_options
    @@mount_at           = "/teaspoon"
    @@root               = nil # will default to Rails.root if left unset
    @@asset_paths        = ["spec/javascripts", "spec/javascripts/stylesheets", "test/javascripts", "test/javascripts/stylesheets"]
    @@fixture_path       = "spec/javascripts/fixtures"
    @@suites             = {"default" => proc{}}
    @@driver_cli_options = nil

    # console runner specific
    cattr_accessor :driver, :server_timeout, :server_port, :fail_fast, :formatters, :suppress_log, :color, :coverage, :coverage_reports, :coverage_output_dir, :server, :statements_coverage_threshold, :functions_coverage_threshold, :branches_coverage_threshold, :lines_coverage_threshold
    @@driver                        = "phantomjs"
    @@server                        = nil
    @@server_port                   = nil
    @@server_timeout                = 20
    @@fail_fast                     = true
    @@formatters                    = "dot"
    @@suppress_log                  = false
    @@color                         = true
    @@coverage                      = false
    @@coverage_reports              = nil
    @@coverage_output_dir           = "coverage"
    @@statements_coverage_threshold = nil
    @@functions_coverage_threshold  = nil
    @@branches_coverage_threshold   = nil
    @@lines_coverage_threshold      = nil

    class Suite
      attr_accessor :matcher, :helper, :stylesheets, :javascripts, :no_coverage, :boot_partial, :js_config, :hooks

      def initialize
        @matcher         = "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"
        @helper          = "spec_helper"
        @javascripts     = ["teaspoon-jasmine"]
        @stylesheets     = ["teaspoon"]
        @no_coverage     = [%r{/lib/ruby/gems/}, %r{/vendor/assets/}, %r{/support/}, %r{/(.+)_helper.}]
        @boot_partial    = nil
        @js_config       = {}

        @hooks = Hash.new {|h, k| h[k] = [] }

        default = Teaspoon.configuration.suites["default"]
        self.instance_eval(&default) if default
        yield self if block_given?
      end

      def use_require=(val) # todo: deprecated in version 0.7.4
        puts "Deprecation Notice: use_require will be removed, specify 'require_js' for config.boot_partial instead."
        self.boot_partial = 'require_js' if val
      end

      def hook(group = :default, &block)
        @hooks[group.to_s] << block
      end
    end

    def self.root=(path)
      @@root = Pathname.new(path.to_s) if path.present?
    end

    def self.suite(name = :default, &block)
      @@suites[name.to_s] = block
    end

    def self.coverage_reports
      return ["text-summary"] if @@coverage_reports.blank?
      return @@coverage_reports if @@coverage_reports.is_a?(Array)
      @@coverage_reports.to_s.split(/,\s?/)
    end

    def self.formatters
      return ["dot"] if @@formatters.blank?
      return @@formatters if @@formatters.is_a?(Array)
      @@formatters.to_s.split(/,\s?/)
    end
  end

  autoload :Formatters, "teaspoon/formatters/base_formatter"
  autoload :Drivers,    "teaspoon/drivers/base_driver"

  mattr_accessor :configuration
  @@configuration = Configuration

  def self.setup
    yield @@configuration
    override_from_env
  end

  private

  def self.override_from_env
    %w(FAIL_FAST SUPPRESS_LOG COLOR COVERAGE).each do |directive|
      next unless ENV[directive].present?
      @@configuration.send("#{directive.downcase}=", ENV[directive] == "true")
    end
    %w(DRIVER DRIVER_CLI_OPTIONS SERVER SERVER_TIMEOUT SERVER_PORT FORMATTERS COVERAGE_REPORTS COVERAGE_OUTPUT_DIR).each do |directive|
      next unless ENV[directive].present?
      @@configuration.send("#{directive.downcase}=", ENV[directive])
    end
  end
end
