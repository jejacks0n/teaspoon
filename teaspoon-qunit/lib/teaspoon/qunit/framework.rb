require "teaspoon/framework/base"

module Teaspoon
  module Qunit
    class Framework < Teaspoon::Framework::Base
      # specify the framework name
      framework_name :qunit

      # register standard versions
      versions = ["1.12.0", "1.13.0", "1.14.0", "1.15.0", "1.16.0", "1.17.1", "1.18.0", "1.19.0"]

      versions.each do |version|
        register_version version, "qunit/#{version}.js",
                                  dependencies: ["teaspoon-qunit.js"],
                                  dev_deps: ["teaspoon/qunit.js"]
      end

      # add asset paths
      add_asset_path File.expand_path("../../../teaspoon/qunit/assets", __FILE__)

      # add custom install templates
      add_template_path File.expand_path("../../../teaspoon/qunit/templates", __FILE__)

      # specify where to install, and add installation steps.
      install_to "test" do
        ext = options[:coffee] ? ".coffee" : ".js"
        copy_file "test_helper#{ext}", "test/javascripts/test_helper#{ext}"
      end

      def self.modify_config(config)
        config.matcher = "{test/javascripts,app/assets}/**/*_test.{js,js.coffee,coffee}"
        config.helper  = "test_helper"
      end
    end
  end
end
