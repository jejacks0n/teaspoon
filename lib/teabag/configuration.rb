require "singleton"

module Teabag
  class Configuration

    include Singleton

    cattr_accessor :root, :mount_at, :asset_paths, :fixture_path, :server_timeout, :suites

    @@mount_at       = "/teabag"
    @@root           = nil # will default to Rails.root if left unset
    @@asset_paths    = ["spec/javascripts", "spec/javascripts/stylesheets"]
    @@fixture_path   = "spec/javascripts/fixtures"
    @@server_timeout = 20
    @@suites         = {}

    def self.root=(path)
      @@root = Pathname.new(path.to_s)
    end

    def self.suite(name = :default, &block)
      @@suites[name.to_s] = block
    end

    class Suite
      attr_accessor :matcher, :helper, :stylesheets, :javascripts

      def initialize
        @matcher     = "{app/assets,lib/assets/,spec/javascripts}/**/*_spec.{js,js.coffee,coffee}"
        @helper      = "spec_helper.js"
        @javascripts = ["teabag/jasmine"] # or ["teabag/mocha"]
        @stylesheets = ["teabag"]

        yield self if block_given?
      end
    end
  end

  mattr_accessor :configuration
  @@configuration = Configuration

  def self.setup
    yield @@configuration
  end
end
