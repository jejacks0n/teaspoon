module Teaspoon
  module Jasmine
    class Framework < Teaspoon::Framework
      # specify the framework name
      framework_name :jasmine

      # register available versions
      register_version "1.3.1", "jasmine/1.3.0", "teaspoon-jasmine"
      register_version "2.2.0", "jasmine/2.2.0", "teaspoon-jasmine"

      # add custom install templates
      add_template_path File.expand_path("../templates", __FILE__)

      # specify where to install, and add installation steps.
      install_to "spec" do
        ext = options[:coffee] ? ".coffee" : ".js"
        copy_file "spec_helper#{ext}", "spec/javascripts/spec_helper#{ext}"
      end
    end
  end
end

Teaspoon.register_framework(Teaspoon::Jasmine::Framework)
