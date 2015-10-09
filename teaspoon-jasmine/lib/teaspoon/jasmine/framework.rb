require "teaspoon/framework/base"

module Teaspoon
  module Jasmine
    class Framework < Teaspoon::Framework::Base
      # specify the framework name
      framework_name :jasmine

      # register standard versions
      register_version "1.3.1", "jasmine/1.3.1.js",
                                dependencies: ["teaspoon-jasmine1.js"],
                                dev_deps: ["teaspoon/jasmine1.js"]

      versions = ["2.0.3", "2.1.3", "2.2.0", "2.2.1", "2.3.4"]

      versions.each do |version|
        register_version version, "jasmine/#{version}.js",
                                  dependencies: ["teaspoon-jasmine2.js"],
                                  dev_deps: ["teaspoon/jasmine2.js"]
      end

      # add asset paths
      add_asset_path File.expand_path("../../../teaspoon/jasmine/assets", __FILE__)

      # add custom install templates
      add_template_path File.expand_path("../../../teaspoon/jasmine/templates", __FILE__)

      # specify where to install, and add installation steps.
      install_to "spec" do
        ext = options[:coffee] ? ".coffee" : ".js"
        copy_file "spec_helper#{ext}", "spec/javascripts/spec_helper#{ext}"
      end
    end
  end
end
