module Teaspoon
  class Error < StandardError
    protected

    def build_message(msg_or_options)
      if msg_or_options.is_a?(String)
        msg_or_options
      else
        yield msg_or_options
      end
    end
  end

  class Failure < Teaspoon::Error
  end

  class EnvironmentNotFound < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Unable to locate environment; searched in [#{options[:searched]}]. Have you run the installer?"
      end)
    end
  end

  # loading / configuration errors

  class UnknownFramework < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        msg = "Unknown framework: expected \"#{options[:name]}\" to be a registered framework. Available frameworks are #{options[:available]}."
        if options[:available].blank?
          msg += " Do you need to update your Gemfile to use the teaspoon-#{options[:name]} gem? If you are upgrading, please see https://github.com/modeset/teaspoon/blob/master/CHANGELOG.md"
        end
      end)
    end
  end

  class UnknownFrameworkVersion < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Unknown framework version: expected \"#{options[:name]}\" to have version #{options[:version]}."
      end)
    end
  end

  class UnknownDriver < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Unknown driver: expected \"#{options[:name]}\" to be a registered driver. Available drivers are #{options[:available]}"
      end)
    end
  end

  class UnknownFormatter < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Unknown formatter: expected \"#{options[:name]}\" to be a registered formatter. Available formatters are #{options[:available]}"
      end)
    end
  end

  class UnspecifiedFramework < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Missing framework: expected \"#{options[:name]}\" suite to configure one using `suite.use_framework`."
      end)
    end
  end

  class UnspecifiedDependencies < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Missing dependencies: expected framework \"#{options[:framework]}\" (#{options[:version]}) to specify the `dependencies` option when registering."
      end)
    end
  end

  class UnknownSuite < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Unknown suite configuration: expected \"#{options[:name]}\" to be a configured suite."
      end)
    end
  end

  class UnknownCoverage < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Unknown coverage configuration: expected \"#{options[:name]}\" to be a configured coverage."
      end)
    end
  end

  class NotFoundInRegistry < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Unknown configuration: expected \"#{options[:name]}\" to be registered. Available options are #{options[:available]}"
      end)
    end
  end

  # general running errors

  class RunnerError < Teaspoon::Error
  end

  class FileWriteError < Teaspoon::Error
  end

  class MissingDependencyError < Teaspoon::Error
    def initialize(msg = nil)
      msg ||= "Unable to locate a required external dependency."
      super(msg)
    end
  end

  class DependencyError < Teaspoon::Error
    def initialize(msg = nil)
      msg ||= "Problem calling out to an external dependency."
      super(msg)
    end
  end

  class ServerError < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Unable to start teaspoon server; #{options[:desc] || 'for an unknown reason'}."
      end)
    end
  end

  class DriverOptionsError < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Malformed driver options#{options[:types] ? ": expected a valid #{options[:types]}." : '.'}"
      end)
    end
  end

  class AssetNotServableError < Teaspoon::Error
    def initialize(msg_or_options)
      super(build_message(msg_or_options) do |options|
        "Unable to serve asset: expected \"#{options[:filename] || 'unknown file'}\" to be within a registered asset path."
      end)
    end
  end

  class IstanbulNotFoundError < Teaspoon::Error
    def initialize(msg = nil)
      msg ||= "You requested coverage reports, but Teaspoon cannot find the istanbul binary. Run: npm install -g istanbul"
      super(msg)
    end
  end
end
