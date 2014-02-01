require "optparse"
require "teaspoon/version"

module Teaspoon
  class CommandLine

    def initialize
      @options = {}
      @options[:files] = opt_parser.parse!

      begin
        require_console
        results = Teaspoon::Console.new(@options).execute
        abort if results
      rescue Teaspoon::EnvironmentNotFound => e
        STDOUT.print("Unable to load Teaspoon environment in {#{Teaspoon::Environment.standard_environments.join(', ')}}.\n")
        STDOUT.print("Consider using -r path/to/teaspoon_env\n")
        abort
      end
    end

    def opt_parser
      OptionParser.new do |parser|
        parser.banner = "Usage: teaspoon [options] [files]\n\n"
        @parser = parser

        opt :environment,
            "-r", "--require FILE",
            "Require Teaspoon environment file."

        #opt :custom_options_file,
        #    "-O", "--options PATH",
        #    "Specify the path to a custom options file."

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

        separator("Filtering")

        opt :suite, "-s", "--suite SUITE",
            "Focus to a specific suite."

        opt :filter, "-g", "--filter FILTER",
            "Filter tests matching a specific filter."

        separator("Output")

        opt :suppress_log, "-q", "--[no-]suppress-log",
            "Suppress logs coming from console[log/debug/error]."

        opt :color, "-c", "--[no-]color",
            "Enable/Disable color output."

        opt :formatters, "-f", "--format FORMATTERS",
            "Specify formatters (comma separated)",
            "  dot (default) - dots",
            "  clean - like dots but doesn't log re-run commands",
            "  junit - junit compatible formatter",
            "  pride - 256 color rainbows where supported",
            "  snowday - makes you feel warm inside",
            "  swayze_or_oprah - random quote from Patrick Swayze or Oprah Winfrey",
            "  tap - test anything protocol formatter",
            "  tap_y - tap_yaml, format used by tapout",
            "  teamcity - teamcity compatible formatter"

        opt :export, "-e", "--export [OUTPUT_PATH]",
            "Exports the test suite as the full HTML (requires wget)."

        opt :coverage_config, "-C", "--coverage CONFIG_NAME",
            "Generate coverage reports using a pre-defined coverage configuration."

        separator("Utility")

        parser.on "-v", "--version", "Display the version.", proc{ puts Teaspoon::VERSION; exit }
        parser.on "-h", "--help", "You're looking at it.", proc { puts parser; exit }
>>>>>>> major adjustments to configuration, and how options are passes into drivers, etc.
      end
    end

    protected

    def separator(message)
      @parser.separator("\n  **** #{message} ****\n\n")
    end

    def opt(config, *args)
      @parser.on(*args, proc{ |value| @options[config] = value})
    end

    private

    def require_console
      require "teaspoon/console"
    end

    def abort
      exit(1)
    end
  end
end
