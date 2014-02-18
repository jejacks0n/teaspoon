module Teaspoon
  module Formatters

    # CONTRIBUTORS:
    # If you add a formatter you should do the following before it will be considered for merging.
    # - add it to this list so it can be autoloaded
    # - write specs for it
    # - add it to the readme so it's documented
    # - add it to the list in command_line.rb so others know it's available
    # - add it to the initializers in /lib/generators/install/templates so it's documented there as well

    autoload :CleanFormatter,         "teaspoon/formatters/clean_formatter"
    autoload :DocumentationFormatter, "teaspoon/formatters/documentation_formatter"
    autoload :DotFormatter,           "teaspoon/formatters/dot_formatter"
    autoload :JsonFormatter,          "teaspoon/formatters/json_formatter"
    autoload :JunitFormatter,         "teaspoon/formatters/junit_formatter"
    autoload :PrideFormatter,         "teaspoon/formatters/pride_formatter"
    autoload :SnowdayFormatter,       "teaspoon/formatters/snowday_formatter"
    autoload :SwayzeOrOprahFormatter, "teaspoon/formatters/swayze_or_oprah_formatter"
    autoload :TapFormatter,           "teaspoon/formatters/tap_formatter"
    autoload :TapYFormatter,          "teaspoon/formatters/tap_y_formatter"
    autoload :TeamcityFormatter,      "teaspoon/formatters/teamcity_formatter"

    class Base

      attr_accessor :total_count, :run_count, :passes, :pendings, :failures, :errors

      def initialize(suite_name = :default, output_file = nil)
        @suite_name  = suite_name.to_s
        @output_file = output_file
        @stdout      = ""
        @suite       = nil
        @last_suite  = nil

        @total_count = 0
        @run_count   = 0
        @passes      = []
        @pendings    = []
        @failures    = []
        @errors      = []
        File.open(@output_file, "w") { |f| f.write("") } if @output_file
      end

      # beginning of the run
      def runner(result, log = true)
        @total_count = result.total
        log_runner(result) if log
      end

      # each suite, before any specs
      def suite(result, log = true)
        @suite = result
        log_suite(result) if log
        @last_suite = result
      end

      # each spec, after the spec has reported to the client runner
      def spec(result, log = true)
        @run_count += 1
        if result.passing?
          @passes << result
        elsif result.pending?
          @pendings << result
        else
          @failures << result
        end
        log_spec(result) if log
        @stdout = ""
      end

      # errors are reported from the onError handler in phantomjs, so they're not linked to a result
      def error(result, log = true)
        @errors << result
        log_error(result) if log
      end

      # exception came from startup errors in the server (will exit after logging)
      def exception(result = {}, log = true)
        log_exception(result) if log
      end

      # console message come from console.log/debug/error
      def console(message, log = true)
        @stdout << message
        log_console(message) if log
      end

      # final report
      def result(result, log = true)
        log_result(result) if log
      end

      # called with the text versions of coverage if configured to do so
      def coverage(message, log = true)
        log_coverage(message) if log
      end

      # called with an array of strings which explain which coverage thresholds failed
      def threshold_failure(message, log = true)
        log_threshold_failure(message) if log
      end

      def complete(failure_count, log = true)
        log_complete(failure_count) if log
      end

      protected

      def log_runner(result); end

      def log_suite(result); end

      def log_spec(result)
        return log_passing_spec(result) if result.passing?
        return log_pending_spec(result) if result.pending?
        log_failing_spec(result)
      end

      def log_passing_spec(result); end

      def log_pending_spec(result); end

      def log_failing_spec(result); end

      def log_error(result); end

      def log_exception(result); end

      def log_console(message); end

      def log_result(result); end

      def log_coverage(message); end

      def log_threshold_failure(message); end

      def log_complete(failure_count); end

      private

      def log_str(str, color_code = nil)
        return log_to_file(str, @output_file) if @output_file
        STDOUT.print(color_code ? colorize(str, color_code) : str)
      end

      def log_line(str = "", color_code = nil)
        return log_to_file("#{str}\n", @output_file) if @output_file
        STDOUT.print("#{color_code ? colorize(str, color_code) : str}\n")
      end

      def log_to_file(str, output_file)
        @_output_file = File.open(output_file, "a") { |f| f.write(str) }
      rescue IOError => e
        raise Teaspoon::FileNotWritable, e.message
      end

      def colorize(str, color_code)
        return str unless Teaspoon.configuration.color || @output_file
        "\e[#{color_code}m#{str}\e[0m"
      end

      def pluralize(str, value)
        value == 1 ? "#{value} #{str}" : "#{value} #{str}s"
      end

      def filename(file)
        file.gsub(%r(^http://127.0.0.1:\d+/assets/), "").gsub(/[\?|&]?body=1/, "")
      end
    end
  end
end
