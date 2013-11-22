module Teaspoon
  module Formatters

    autoload :DotFormatter,           'teaspoon/formatters/dot_formatter'
    autoload :CleanFormatter,         'teaspoon/formatters/clean_formatter'
    autoload :TapYFormatter,          'teaspoon/formatters/tap_y_formatter'
    autoload :TapFormatter,           'teaspoon/formatters/tap_formatter'
    autoload :SwayzeOrOprahFormatter, 'teaspoon/formatters/swayze_or_oprah_formatter'
    autoload :TeamcityFormatter,      'teaspoon/formatters/teamcity_formatter'
    autoload :JunitFormatter,         'teaspoon/formatters/junit_formatter'

    class BaseFormatter

      attr_accessor :total, :passes, :pendings, :failures, :errors

      def initialize(suite_name = :default)
        @suite_name = suite_name.to_s
        @total    = 0
        @passes   = []
        @pendings = []
        @failures = []
        @errors   = []
      end

      def spec(result)
        @total += 1
        if result.passing?
          @passes << result
        elsif result.pending?
          @pendings << result
        else
          @failures << result
        end
      end

      def result(results)
        log_coverage(results["coverage"])
        return if failures.size == 0
        STDOUT.print("\n")
        raise Teaspoon::Failure if Teaspoon.configuration.fail_fast
      end

      # Exceptions come from startup errors in the server
      def exception(exception = {})
        raise Teaspoon::RunnerException
      end

      def suppress_logs?
        false
      end

      private

      def log_coverage(data)
        return if data.blank? || suppress_logs?
        STDOUT.print(Teaspoon::Coverage.new(data).reports)
      end
    end
  end
end
