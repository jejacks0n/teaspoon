require "teaspoon"
require "teaspoon/qunit/version"

module Teaspoon
  module Qunit
    class Framework < Teaspoon::Framework
      # specify the framework name
      framework_name :qunit

      # register available versions
      register_version "1.12.0", "qunit/1.10.0", "teaspoon-qunit"
      register_version "1.14.0", "qunit/1.14.0", "teaspoon-qunit"

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
