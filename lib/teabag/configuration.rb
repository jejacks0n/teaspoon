require "singleton"

module Teabag
  class Configuration

    include Singleton

    cattr_accessor :root, :mount_at, :asset_paths, :fixture_path, :formatters, :server_timeout, :fail_fast, :suppress_log, :suites

    @@mount_at          = "/teabag"
    @@root              = nil # will default to Rails.root if left unset
    @@asset_paths       = ["spec/javascripts", "spec/javascripts/stylesheets"]
    @@fixture_path      = "spec/javascripts/fixtures"
    @@suites            = {}

    # console runner specific
    @@formatters        = "dot"
    @@server_timeout    = 20
    @@fail_fast         = true
    @@suppress_log      = false

    def self.root=(path)
      @@root = Pathname.new(path.to_s) if path.present?
    end

    def self.suite(name = :default, &block)
      @@suites[name.to_s] = block
    end

    self.suite(:default) {}

    class Suite
      attr_accessor :matcher, :helper, :stylesheets, :javascripts

      def initialize
        @matcher     = "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"
        @helper      = "spec_helper"
        @javascripts = ["teabag-jasmine"]
        @stylesheets = ["teabag"]

        yield self if block_given?
      end
    end
  end

  autoload :Formatters, "teabag/formatters/base_formatter"

  mattr_accessor :configuration
  @@configuration = Configuration

  def self.setup
    yield @@configuration
    override_from_env
  end

  private

  def self.override_from_env
    %w(FAIL_FAST SUPPRESS_LOG).each do |directive|
      next unless ENV[directive].present?
      @@configuration.send("#{directive.downcase}=", ENV[directive] == "true")
    end
    %w(FORMATTERS).each do |directive|
      next unless ENV[directive].present?
      @@configuration.send("#{directive.downcase}=", ENV[directive])
    end
  end
end
