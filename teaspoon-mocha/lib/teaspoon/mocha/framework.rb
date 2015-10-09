require "teaspoon/framework/base"

module Teaspoon
  module Mocha
    class Framework < Teaspoon::Framework::Base
      # specify the framework name
      framework_name :mocha

      # register standard versions
      versions = ["1.10.0", "1.17.1", "1.18.2", "1.19.0", "2.0.1", "2.1.0", "2.2.4", "2.2.5", "2.3.3"]

      versions.each do |version|
        register_version version, "mocha/#{version}.js",
                                   dependencies: ["teaspoon-mocha.js"],
                                   dev_deps: ["teaspoon/mocha.js"]
      end

      # add asset paths
      add_asset_path File.expand_path("../../../teaspoon/mocha/assets", __FILE__)

      # add custom install templates
      add_template_path File.expand_path("../../../teaspoon/mocha/templates", __FILE__)

      # specify where to install, and add installation steps.
      install_to "spec" do
        ext = options[:coffee] ? ".coffee" : ".js"
        copy_file "spec_helper#{ext}", "spec/javascripts/spec_helper#{ext}"
      end
    end
  end
end
