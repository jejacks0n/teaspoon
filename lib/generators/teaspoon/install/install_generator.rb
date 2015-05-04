require "teaspoon/exceptions"
require "rails/generators"

module Teaspoon
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Installs the Teaspoon initializer into your application."

      class_option :framework,
                   type: :string,
                   aliases: "-t",
                   default: Teaspoon::Framework.default,
                   desc: "Specify which test framework to use (Available: #{Teaspoon::Framework.available.keys.join(', ')})"

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

      class_option :documentation,
                   type: :boolean,
                   aliases: ["-d"],
                   default: true,
                   desc: "Install the teaspoon_env.rb with comment documentation"

      class_option :partials,
                   type: :boolean,
                   aliases: "-p",
                   default: false,
                   desc: "Copy the boot and body partials"

      def verify_framework_and_version
        version.present?
        framework
      rescue
        abort_with_message if behavior == :invoke
      end

      def copy_environment
        source = options[:documentation] ? "env_comments.rb.tt" : "env.rb.tt"
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
        Teaspoon::Framework.available.map do |framework, options|
          klass = Teaspoon::Framework.fetch(framework)
          "#{framework}: versions[#{klass.versions.join(', ')}]"
        end
      end

      def framework
        @framework ||= begin
          framework = Teaspoon::Framework.fetch(options[:framework])
          source_paths
          @source_paths = framework.template_paths + @source_paths
          framework
        end
      end

      def suite
        @suite ||= begin
          config = Teaspoon::Configuration::Suite.new
          framework.modify_config(config)
          config
        end
      end

      def version
        @version ||= options[:version] ? determine_requested_version : framework.versions.last
      end

      def determine_requested_version
        return options[:version] if framework.versions.include?(options[:version])
        raise Teaspoon::UnknownFrameworkVersion.new(name: framework.name, version: options[:version])
      end

      def abort_with_message
        if Teaspoon::Framework.available.empty?
          readme "MISSING_FRAMEWORK"
        else
          message = "Unknown framework: #{options[:framework]}#{options[:version] ? "[#{options[:version]}]" : ''}"
          message << "\n  Available: #{described_frameworks.join("\n             ")}"
          say_status message, nil, :red
        end
        exit(1)
      end
    end
  end
end
