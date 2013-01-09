require "teabag/exceptions"

module Teabag
  module Environment

    def self.load(options = {})
      unless rails_loaded?
        require_environment(options[:environment])
        raise "Rails environment not found." unless rails_loaded?
      end

      require "teabag"

      configure_from_options(options)
    end

    def self.require_environment(override = nil)
      return require_env(File.expand_path(override, Dir.pwd)) if override

      standard_environments.each do |filename|
        file = File.expand_path(filename, Dir.pwd)
        return require_env(file) if File.exists?(file)
      end

      raise Teabag::EnvironmentNotFound
    end

    def self.standard_environments
      ["spec/teabag_env.rb", "test/teabag_env.rb", "teabag_env.rb"]
    end

    def self.configure_from_options(options)
      options.each do |key, value|
        Teabag.configuration.send("#{key.downcase}=", value) if Teabag.configuration.respond_to?("#{key.downcase}=")
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
