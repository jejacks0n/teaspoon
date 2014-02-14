require "optparse"
require "teaspoon/version"

module Teaspoon
  class CommandLine

    def initialize
      @options = {}
      @files = opt_parser.parse!

      begin
        require_console
        abort if Teaspoon::Console.new(@options, @files).execute
      rescue Teaspoon::EnvironmentNotFound => e
        STDOUT.print "Unable to load Teaspoon environment in {#{Teaspoon::Environment.standard_environments.join(', ')}}.\n"
        STDOUT.print "Consider using -r path/to/teaspoon_env\n"
        abort
      end
    end

    def opt_parser
      OptionParser.new do |parser|
        parser.banner = "Usage: teaspoon [options] [files]\n\n"

        parser.on("-r", "--require FILE", "Require Teaspoon environment file.") do |file|
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

        parser.on("-o", "--driver-cli-options OPTIONS", "Specify driver-specific options string to pass into the driver, e.g.",
                        "  '--ssl-protocol=any --ssl-certificates-path=/path/to/certs' could be used for phantomjs",
                        "  Currently driver CLI options are only supported for phantomjs. It will be ignored if using the selenium driver.") do |driver_cli_options|
          @options[:driver_cli_options] = driver_cli_options
        end

        parser.on("-t", "--timeout SECONDS", "Sets the timeout for the suite to finish.") do |seconds|
          @options[:timeout] = seconds
        end

        parser.on("--server SERVER", "Sets server to use with Rack.") do |server|
          @options[:server] = server
        end

        parser.on("--server-timeout SECONDS", "Sets the timeout for the server to start.") do |seconds|
          @options[:server_timeout] = seconds
        end

        parser.on("--server-port PORT", "Sets the server to use a specific port.") do |port|
          @options[:server_port] = port
        end

        parser.on("--[no-]fail-fast", "Abort after the first failing suite.") do |bool|
          @options[:fail_fast] = bool
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
                  "  dot (default) - dots",
                  "  tap_y - format used by tapout",
                  "  swayze_or_oprah - random quote from Patrick Swayze or Oprah Winfrey") do |formatters|
          @options[:formatters] = formatters
        end

        parser.on("-q", "--[no-]suppress-log", "Suppress logs coming from console[log/debug/error].") do |bool|
          @options[:suppress_log] = bool
        end

        parser.on("-c", "--[no-]colour", "Enable/Disable color output.") do |bool|
          @options[:color] = bool
        end

        parser.separator("\n  **** Coverage ****\n\n")

        parser.on("-C", "--coverage", "Generate coverage report (requires Istanbul).") do |bool|
          @options[:coverage] = bool
        end

        parser.on("-R", "--coverage-reports FORMATS", "Specify which coverage reports to generate (comma separated)",
                  "  text-summary (default) - compact text summary in results",
                  "  text - text table with coverage for all files in results",
                  "  html - HTML files with annotated source code",
                  "  lcov - html + lcov files",
                  "  lcovonly - an lcov.info file",
                  "  cobertura - cobertura-coverage.xml used by Hudson") do |reports|
          @options[:coverage] = true
          @options[:coverage_reports] = reports
        end

        parser.on("-O", "--coverage-output-dir DIR", "Specify directory where coverage reports should be generated.") do |dir|
          @options[:coverage_output_dir] = dir
        end

        parser.separator("\n  **** Coverage Thresholds ****\n\n")

        parser.on("-S", "--statements-coverage-threshold THRESHOLD", "Specify the statements coverage threshold.",
                  " If this is a positive number, it is the minimum percentage required for coverage to not fail.",
                  " If it is a negative number, it is the maximum number of uncovered statements allowed to not fail.") do |threshold|
          @options[:statements_coverage_threshold] = threshold
        end

        parser.on("-F", "--functions-coverage-threshold THRESHOLD", "Specify the functions coverage threshold.",
                  " If this is a positive number, it is the minimum percentage required for coverage to not fail.",
                  " If it is a negative number, it is the maximum number of uncovered functions allowed to not fail.") do |threshold|
          @options[:functions_coverage_threshold] = threshold
        end

        parser.on("-B", "--branches-coverage-threshold THRESHOLD", "Specify the branches coverage threshold.",
                  " If this is a positive number, it is the minimum percentage required for coverage to not fail.",
                  " If it is a negative number, it is the maximum number of uncovered branches allowed to not fail.") do |threshold|
          @options[:branches_coverage_threshold] = threshold
        end

        parser.on("-L", "--lines-coverage-threshold THRESHOLD", "Specify the lines coverage threshold.",
                  " If this is a positive number, it is the minimum percentage required for coverage to not fail.",
                  " If it is a negative number, it is the maximum number of uncovered lines allowed to not fail.") do |threshold|
          @options[:lines_coverage_threshold] = threshold
        end

        parser.separator("\n  **** Utility ****\n\n")

        parser.on("-v", "--version", "Display the version.") do
          puts Teaspoon::VERSION
          exit
        end

        parser.on("-h", "--help", "You're looking at it.") do
          puts parser
          exit
        end
      end
    end

    def require_console
      require "teaspoon/console"
    end

    def abort
      exit(1)
    end
  end
end
