module Teaspoon
  module Mocha
    class Framework < Teaspoon::Framework
      # specify the framework name
      framework_name :mocha

      # register available versions
      register_version "1.10.0", "mocha/1.10.0", "teaspoon-mocha"
      register_version "1.17.1", "mocha/1.17.1", "teaspoon-mocha"

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

Teaspoon.register_framework(Teaspoon::Mocha::Framework)
