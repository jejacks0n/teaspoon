module Teaspoon
  module Generators
    class InstallGenerator < Rails::Generators::Base

      source_root File.expand_path("../", __FILE__)

      desc "Installs the Teaspoon initializer into your application."

      class_option :framework, type: :string,
                   aliases: "-t",
                   default: "jasmine",
                   desc:    "Specify which test framework to use (Available: jasmine, mocha, or qunit)"

      class_option :coffee, type: :boolean,
                   aliases: "-c",
                   default: false,
                   desc:    "Generate a CoffeeScript spec helper instead of Javascript"

      class_option :no_comments, type: :boolean,
                   aliases: "-q",
                   default: false,
                   desc:    "Install the teaspoon_env.rb without comments"

      class_option :partials, type: :boolean,
                   aliases: "-p",
                   default: false,
                   desc:    "Copy the boot and body partials"

      def validate_framework
        return if frameworks.include?(options[:framework])
        puts "Unknown framework -- available #{frameworks.join(", ")}"
        exit(1)
      end

      def copy_environment
        source = options[:no_comments] ? "env.rb" : "env_comments.rb"
        copy_file "templates/#{framework}/#{source}", "#{framework_type}/teaspoon_env.rb"
      end

      def create_structure
        empty_directory "#{framework_type}/javascripts/support"
        empty_directory "#{framework_type}/javascripts/fixtures"
      end

      def copy_spec_helper
        copy_file "templates/#{framework}/#{framework_type}_helper.#{helper_ext}", "#{framework_type}/javascripts/#{framework_type}_helper.#{helper_ext}"
      end

      def copy_partials
        return unless options[:partials]
        copy_file "templates/_boot.html.erb", "/#{framework_type}/javascripts/fixtures/_boot.html.erb"
        copy_file "templates/_body.html.erb", "/#{framework_type}/javascripts/fixtures/_body.html.erb"
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
end
