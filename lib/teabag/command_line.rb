require "optparse"
require "teabag/version"

module Teabag
  class CommandLine

    def initialize
      @options = {}
      @files = opt_parser.parse!

      begin
        require_console
        abort if Teabag::Console.new(@options, @files).execute
      rescue Teabag::EnvironmentNotFound => e
        STDOUT.print "Unable to load Teabag environment in {#{Teabag::Environment.standard_environments.join(', ')}}.\n"
        STDOUT.print "Consider using -r path/to/teabag_env\n"
        abort
      end
    end

    def opt_parser
      OptionParser.new do |parser|
        parser.banner = "Usage: teabag [options] [files]\n\n"

        parser.on("-r", "--require FILE", "Require Teabag environment file.") do |file|
          @options[:environment] = file
        end

        #parser.on("-O", "--options PATH", "Specify the path to a custom options file.") do |path|
        #  @options[:custom_options_file] = path
        #end

        parser.on("-d", "--driver DRIVER", "Specify driver:",
                  "  phantomjs (default)",
                  "  selenium") do |driver|
          @options[:driver] = driver
        end

        parser.on("--server-timeout SECONDS", "Sets the timeout for the server to start.") do |seconds|
          @options[:server_timeout] = seconds
        end

        parser.on("--[no-]fail-fast", "Abort after the first failing suite.") do |o|
          @options[:fail_fast] = o
        end

        parser.separator("\n  **** Filtering ****\n\n")

        parser.on("-s", "--suite SUITE", "Focus to a specific suite.") do |suite|
          @options[:suite] = suite
        end

        parser.on("-g", "--filter FILTER", "Filter tests matching a specific filter.") do |filter|
          @options[:filter] = filter
        end

        parser.separator("\n  **** Output ****\n\n")

        parser.on("-f", "--format FORMATTERS", "Specify formatters (comma separated)",
                  "  dot (default)",
                  "  tap_y",
                  "  swayze_or_oprah") do |formatters|
          @options[:formatters] = formatters
        end

        parser.on("-q", "--[no-]suppress-log", "Suppress logs coming from console[log/debug/error].") do |o|
          @options[:suppress_log] = o
        end

        parser.on("-c", "--[no-]colour", "Enable/Disable color output.") do |o|
          @options[:color] = o
        end

        parser.separator("\n  **** Utility ****\n\n")

        parser.on("-v", "--version", "Display the version.") do
          puts Teabag::VERSION
          exit
        end

        parser.on("-h", "--help", "You're looking at it.") do
          puts parser
          exit
        end
      end
    end

    def require_console
      require "teabag/console"
    end

    def abort
      exit(1)
    end
  end
end
