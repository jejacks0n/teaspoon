module Teabag::Generators
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../", __FILE__)

    desc "Installs the Teabag initializer into your application."

    class_option :framework, type: :string,
                 aliases: "-t",
                 default: "jasmine",
                 desc:    "Specify which test framework to use (Available: jasmine, mocha, or qunit)"

    class_option :coffee, type: :boolean,
                 aliases: "-c",
                 default: false,
                 desc:    "Generate a CoffeeScript spec helper (instead of Javascript)"

    class_option :env, type: :boolean,
                 aliases: "-e",
                 default: true,
                 desc:    "Create the teabag_env.rb file used by the command line interface"

    def validate_framework
      return if frameworks.include?(options[:framework])
      puts "Unknown framework -- Known: #{frameworks.join(', ')}"
      exit
    end

    def copy_initializers
      copy_file "templates/#{framework}/initializer.rb", "config/initializers/teabag.rb"
      copy_file "templates/env.rb", "#{framework_type}/teabag_env.rb" if options[:env]
    end

    def create_structure
      empty_directory "#{framework_type}/javascripts/support"
      empty_directory "#{framework_type}/javascripts/fixtures"
    end

    def copy_spec_helper
      copy_file "templates/#{framework}/#{framework_type}_helper.#{helper_ext}", "#{framework_type}/javascripts/#{framework_type}_helper.#{helper_ext}"
    end

    def display_readme
      readme "POST_INSTALL" if behavior == :invoke
    end

    private

    def framework
      options[:framework]
    end

    def frameworks
      %w{jasmine mocha qunit}
    end

    def helper_ext
      (options[:coffee]) ? "coffee" : "js"
    end

    def framework_type
      (options[:framework] == "qunit") ? "test" : "spec"
    end

  end
end
