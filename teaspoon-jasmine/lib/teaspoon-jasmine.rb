require "teaspoon"
require "teaspoon/jasmine/version"

module Teaspoon
  module Jasmine
    class Framework < Teaspoon::Framework
      # specify the framework name
      framework_name :jasmine

      # register standard versions
      register_version "1.3.1", "jasmine/1.3.1.js",
                                dependencies: ["teaspoon-jasmine1.js"],
                                dev_deps: ["teaspoon/jasmine1.js"]

      register_version "2.2.0", "jasmine/2.2.0.js",
                                dependencies: ["teaspoon-jasmine2.js"],
                                dev_deps: ["teaspoon/jasmine2.js"]

      # add asset paths
      add_asset_path File.expand_path("../teaspoon/jasmine/assets", __FILE__)

      # add custom install templates
      add_template_path File.expand_path("../teaspoon/jasmine/templates", __FILE__)

      # specify where to install, and add installation steps.
      install_to "spec" do
        ext = options[:coffee] ? ".coffee" : ".js"
        copy_file "spec_helper#{ext}", "spec/javascripts/spec_helper#{ext}"
      end
    end
  end
end

Teaspoon.register_framework(Teaspoon::Jasmine::Framework)
