require "teaspoon/exceptions"

module Teaspoon
  module Environment

    def self.load(options = {})
      require_environment(options[:environment])
      raise "Rails environment not found." unless rails_loaded?

      require "teaspoon"
      require "teaspoon/server"
      require "teaspoon/runner"
      require "teaspoon/coverage"
      require "teaspoon/exporter"

      Teaspoon.configuration.override_from_options(options)
      Teaspoon::ExceptionHandling.add_rails_handling
    end

    def self.require_environment(override = nil)
      override ||= ENV["TEASPOON_ENV"]
      if override
        override = File.expand_path(override, Dir.pwd)
        ENV["TEASPOON_ENV"] = override
        return require_env(override)
      end

      standard_environments.each do |filename|
        file = File.expand_path(filename, Dir.pwd)
        return require_env(file) if File.exists?(file)
        #file = File.expand_path(filename, File.join(Dir.pwd, '../..'))
        #return require_env(file) if File.exists?(file)
      end

      raise Teaspoon::EnvironmentNotFound, "Unable to load Teaspoon environment in {#{standard_environments.join(', ')}}"
    end

    def self.standard_environments
      ["spec/teaspoon_env.rb", "test/teaspoon_env.rb", "teaspoon_env.rb"]
    end

    private

    def self.require_env(file)
      ::Kernel.load(file)
    end

    def self.rails_loaded?
      defined?(Rails)
    end
  end
end
