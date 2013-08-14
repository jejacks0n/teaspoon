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

  end
end
