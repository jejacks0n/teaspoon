require "singleton"

module Teabag
  class Configuration

    include Singleton

    cattr_accessor :mount_at, :root, :asset_paths, :fixture_path, :suites
    @@mount_at       = "/teabag"
    @@root           = nil # will default to Rails.root if left unset
    @@asset_paths    = ["spec/javascripts", "spec/javascripts/stylesheets", "test/javascripts", "test/javascripts/stylesheets"]
    @@fixture_path   = "spec/javascripts/fixtures"
    @@suites         = {"default" => proc{}}

    # console runner specific
    cattr_accessor :driver, :phantomjs_bin, :server_timeout, :fail_fast, :formatters, :suppress_log, :color
    @@driver         = "phantomjs"
    @@phantomjs_bin  = nil
    @@server_timeout = 20
    @@fail_fast      = true
    @@formatters     = "dot"
    @@suppress_log   = false
    @@color          = true

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

    def self.root=(path)
      @@root = Pathname.new(path.to_s) if path.present?
    end

    def self.suite(name = :default, &block)
      @@suites[name.to_s] = block
    end

  end

  autoload :Formatters, "teabag/formatters/base_formatter"
  autoload :Drivers,    "teabag/drivers/base_driver"

  mattr_accessor :configuration
  @@configuration = Configuration

  def self.setup
    yield @@configuration
    override_from_env
  end

  private

  def self.override_from_env
    %w(FAIL_FAST SUPPRESS_LOG COLOR).each do |directive|
      next unless ENV[directive].present?
      @@configuration.send("#{directive.downcase}=", ENV[directive] == "true")
    end
    %w(DRIVER FORMATTERS SERVER_TIMEOUT PHANTOMJS_BIN).each do |directive|
      next unless ENV[directive].present?
      @@configuration.send("#{directive.downcase}=", ENV[directive])
    end
  end
end
