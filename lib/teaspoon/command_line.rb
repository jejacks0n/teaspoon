require "optparse"
require "teaspoon/version"
require "teaspoon/exceptions"

module Teaspoon
  class CommandLine

    def initialize
      @options = {}
      @options[:files] = opt_parser.parse!

      require_console
      abort if Teaspoon::Console.new(@options).failures?
    rescue Teaspoon::EnvironmentNotFound => e
      abort("#{e.message}\nConsider using -r path/to/teaspoon_env\n")
    end

    def opt_parser
      OptionParser.new do |parser|
        @parser = parser
        @parser.banner = "Usage: teaspoon [options] [files]\n\n"

        opts_for_general
        opts_for_filtering
        opts_for_output
        opts_for_coverage
        opts_for_utility
      end
    end

    protected

    def opts_for_general
      opt :environment,
        "-r", "--require FILE",
        "Require Teaspoon environment file."

      #opt :custom_options_file,
      #  "-O", "--options PATH",
      #  "Specify the path to a custom options file."

      opt :driver, "-d", "--driver DRIVER",
        "Specify driver:",
        "  phantomjs (default)",
        "  selenium"

      opt :driver_options, "--driver-options OPTIONS",
        "Specify driver-specific options to pass into the driver.",
        "  e.g. \"--ssl-protocol=any --ssl-certificates-path=/path/to/certs\".",
        "  Driver options are only supported with phantomjs."

      opt :driver_timeout, "--driver-timeout SECONDS",
        "Sets the timeout for the driver to wait before exiting."

      opt :server, "--server SERVER",
        "Sets server to use with Rack.",
        "  e.g. webrick, thin"

      opt :server_port, "--server-port PORT",
        "Sets the server to use a specific port."

      opt :server_timeout, "--server-timeout SECONDS",
        "Sets the timeout that the server must start within."

      opt :fail_fast, "-F", "--[no-]fail-fast",
        "Abort after the first failing suite."
    end

    def opts_for_filtering
      separator("Filtering")

      opt :suite, "-s", "--suite SUITE",
        "Focus to a specific suite."

      opt :filter, "-g", "--filter FILTER",
        "Filter tests matching a specific filter."
    end

    def opts_for_output
      separator("Output")

      opt :suppress_log, "-q", "--[no-]suppress-log",
        "Suppress logs coming from console[log/debug/error]."

      opt :color, "-c", "--[no-]color",
        "Enable/Disable color output."

      opt :export, "-e", "--export [OUTPUT_PATH]",
        "Exports the test suite as the full HTML (requires wget)."

      opt :formatters, "-f", "--format FORMATTERS",
        "Specify formatters (comma separated)",
        "  dot (default) - dots",
        "  documentation - descriptive documentation",
        "  clean - like dots but doesn't log re-run commands",
        "  json - json formatter (raw teaspoon)",
        "  junit - junit compatible formatter",
        "  pride - yay rainbows!",
        "  snowday - makes you feel warm inside",
        "  swayze_or_oprah - quote from either Patrick Swayze or Oprah Winfrey",
        "  tap - test anything protocol formatter",
        "  tap_y - tap_yaml, format used by tapout",
        "  teamcity - teamcity compatible formatter"
    end

    def opts_for_coverage
      separator("Coverage")

      opt :use_coverage, "-C", "--coverage CONFIG_NAME",
        "Generate coverage reports using a pre-defined coverage configuration."
    end

    def opts_for_utility
      separator("Utility")

      @parser.on "-v", "--version", "Display the version.", proc{ STDOUT.print("#{Teaspoon::VERSION}\n"); exit }
      @parser.on "-h", "--help", "You're looking at it.", proc { STDOUT.print("#{@parser}\n"); exit }
    end

    private

    def separator(message)
      @parser.separator("\n  **** #{message} ****\n\n")
    end

    def opt(config, *args)
      @parser.on(*args, proc{ |value| @options[config] = value })
    end

    def require_console
      require "teaspoon/console"
    end

    def abort(message = nil)
      STDOUT.print(message) if message
      exit(1)
    end
  end
end
