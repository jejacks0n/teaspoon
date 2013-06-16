require "teaspoon/exceptions"

module Teaspoon
  module Environment

    def self.load(options = {})
      unless rails_loaded?
        require_environment(options[:environment])
        raise "Rails environment not found." unless rails_loaded?
      end

      require "teaspoon"
      require "teaspoon/suite"
      require "teaspoon/server"

      configure_from_options(options)
    end

    def self.require_environment(override = nil)
      return require_env(File.expand_path(override, Dir.pwd)) if override

      standard_environments.each do |filename|
        file = File.expand_path(filename, Dir.pwd)
        return require_env(file) if File.exists?(file)
      end

      return self.require_environment if self.resolve_old_name!
      raise Teaspoon::EnvironmentNotFound
    end

    def self.standard_environments
      ["spec/teaspoon_env.rb", "test/teaspoon_env.rb", "teaspoon_env.rb"]
    end

    def self.configure_from_options(options)
      options.each do |key, value|
        Teaspoon.configuration.send("#{key.downcase}=", value) if Teaspoon.configuration.respond_to?("#{key.downcase}=")
      end
    end

    def self.require_env(file)
      require(file)
    end

    def self.rails_loaded?
      defined?(Rails)
    end

    # todo: remove eventually
    # this will attempt to rename and fix your old teabag env files.
    def self.resolve_old_name!
      ["spec/teabag_env.rb", "test/teabag_env.rb", "teabag_env.rb"].each do |filename|
        file = File.expand_path(filename, Dir.pwd)
        if File.exists?(file)
          puts "Deprecation Warning: An environment file was found under an old name: '#{filename}'"
          begin
            puts "Attempting to rename and fix it for you."
            content = File.read(file).gsub('Teabag', 'Teaspoon').gsub('teabag', 'teaspoon')
            File.write(File.expand_path(filename.gsub('teabag', 'teaspoon'), Dir.pwd), content)
            File.delete(file)
            return true
          rescue
            puts "Unable to rename and fix the file."
            puts "Please rename this file to '#{filename.gsub('teabag', 'teaspoon')}' and replace any reference to teabag with teaspoon before continuing."
            exit(0)
          end
        end
      end
      false
    end
  end
end
