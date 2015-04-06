require "teaspoon/exceptions"

module Teaspoon
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Installs the Teaspoon initializer into your application."

      class_option :framework,
                   type: :string,
                   aliases: "-t",
                   default: Teaspoon.frameworks.keys.first,
                   desc: "Specify which test framework to use (Available: #{Teaspoon.frameworks.keys.join(', ')})"

      class_option :version,
                   type: :string,
                   aliases: "-v",
                   default: nil,
                   desc: "Specify the framework version to use (Depends on the framework)"

      class_option :coffee,
                   type: :boolean,
                   aliases: "-c",
                   default: false,
                   desc: "Generate a CoffeeScript spec helper instead of Javascript"

      class_option :no_comments,
                   type: :boolean,
                   aliases: ["-q", "no-comments"],
                   default: false,
                   desc: "Install the teaspoon_env.rb without comments"

      class_option :partials,
                   type: :boolean,
                   aliases: "-p",
                   default: false,
                   desc: "Copy the boot and body partials"

      def verify_framework_and_version
        version.present?
      rescue
        if Teaspoon.frameworks.length == 0
          readme "MISSING_FRAMEWORK"
        else
          message = "Unknown framework: #{options[:framework]}#{options[:version].nil? ? "[#{options[:version]}]" : ''}"
          message << "\n  Available: #{described_frameworks.join("\n             ")}"
          say_status message, :red
        end
        exit(1)
      end

      def copy_environment
        source = options[:no_comments] ? "env.rb.tt" : "env_comments.rb.tt"
        template source, "#{framework.install_path}/teaspoon_env.rb"
      end

      def create_structure
        empty_directory "#{framework.install_path}/javascripts/support"
        empty_directory "#{framework.install_path}/javascripts/fixtures"
      end

      def install_framework_files
        instance_eval(&framework.install_callback)
      end

      def copy_partials
        return unless options[:partials]
        copy_file "_boot.html.erb", "#{framework.install_path}/javascripts/fixtures/_boot.html.erb"
        copy_file "_body.html.erb", "#{framework.install_path}/javascripts/fixtures/_body.html.erb"
      end

      def display_post_install
        readme "POST_INSTALL" if behavior == :invoke
      end

      private

      def described_frameworks
        Teaspoon.frameworks.map do |name, klass|
          "#{name}: versions[#{klass.new(suite).versions.join(', ')}]"
        end
      end

      def framework
        @framework ||= begin
          klass = Teaspoon.frameworks[options[:framework].to_sym]
          raise Teaspoon::UnknownFramework.new(name: options[:framework]) unless klass
          framework = klass.new(suite)
          source_paths
          @source_paths = framework.template_paths + @source_paths
          framework
        end
      end

      def suite
        @suite ||= Teaspoon::Configuration::Suite.new
      end

      def version
        @version ||= begin
          if options[:version]
            if framework.versions.include?(options[:version])
              options[:version]
            else
              raise Teaspoon::UnknownFrameworkVersion.new(name: framework.name, version: options[:version])
            end
          else
            framework.versions.last
          end
        end
      end
    end
  end
end
