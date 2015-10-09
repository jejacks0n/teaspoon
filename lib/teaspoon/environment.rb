require "teaspoon/exceptions"

module Teaspoon
  module Environment
    def self.load(options = {})
      load_rails
      Teaspoon.abort("Rails environment not found.", 1) unless rails_loaded?

      require "teaspoon"
      require "teaspoon/server"
      require "teaspoon/runner"
      require "teaspoon/coverage"
      require "teaspoon/exporter"

      Teaspoon.configuration.override_from_options(options)
      Teaspoon::Engine::ExceptionHandling.add_rails_handling
    end

    def self.require_environment(override = nil)
      require_env(find_env(override))
    end

    def self.check_env!(override = nil)
      find_env(override)
    end

    private

    def self.find_env(override = nil)
      override ||= ENV["TEASPOON_ENV"]
      env_files = override && !override.empty? ? [override] : standard_environments

      env_files.each do |filename|
        file = File.expand_path(filename, Dir.pwd)
        ENV["TEASPOON_ENV"] = file if override
        return file if File.exists?(file)
      end

      raise Teaspoon::EnvironmentNotFound.new(searched: env_files.join(", "))
    end

    def self.standard_environments
      ["spec/teaspoon_env.rb", "test/teaspoon_env.rb", "teaspoon_env.rb"]
    end

    def self.require_env(file)
      ::Kernel.load(file)
    end

    def self.rails_loaded?
      !!defined?(Rails)
    end

    def self.load_rails
      rails_env = ENV["TEASPOON_RAILS_ENV"] || File.expand_path("config/environment.rb", Dir.pwd)

      # Try to load rails, assume teaspoon_env will do it if the expected
      # environment isn't found.
      if File.exists?(rails_env)
        require rails_env
      else
        require_environment
      end
    end
  end
end
