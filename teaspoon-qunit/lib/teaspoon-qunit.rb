require "teaspoon"
require "teaspoon/qunit/version"

module Teaspoon
  module Qunit
    class Framework < Teaspoon::Framework
      # specify the framework name
      framework_name :qunit

      version = ["1.12.0", "1.13.0", "1.14.0", "1.15.0", "1.16.0", "1.17.1", "1.18.0"]

      version.each do |version|
        # register developer versions
        register_version "#{version}-dev", "qunit/#{version}.js", "teaspoon/qunit.js"

        # register standard versions
        register_version version, "qunit/#{version}.js", "teaspoon-qunit.js"
      end

      # add asset paths
      add_asset_path File.expand_path("../teaspoon/qunit/assets", __FILE__)

      # add custom install templates
      add_template_path File.expand_path("../teaspoon/qunit/templates", __FILE__)

      # specify where to install, and add installation steps.
      install_to "test" do
        ext = options[:coffee] ? ".coffee" : ".js"
        copy_file "test_helper#{ext}", "test/javascripts/test_helper#{ext}"
      end

      # modify default configuration
      def initialize(config)
        config.matcher = "{test/javascripts,app/assets}/**/*_test.{js,js.coffee,coffee}"
        config.helper  = "test_helper"
      end
    end
  end
end

Teaspoon.register_framework(Teaspoon::Qunit::Framework)
