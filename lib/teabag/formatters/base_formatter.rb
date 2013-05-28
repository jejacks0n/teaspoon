module Teabag
  module Formatters

    autoload :DotFormatter,           'teabag/formatters/dot_formatter'
    autoload :CleanFormatter,         'teabag/formatters/clean_formatter'
    autoload :TapYFormatter,          'teabag/formatters/tap_y_formatter'
    autoload :TapFormatter,           'teabag/formatters/tap_formatter'
    autoload :SwayzeOrOprahFormatter, 'teabag/formatters/swayze_or_oprah_formatter'
    autoload :TeamcityFormatter,      'teabag/formatters/teamcity_formatter'

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
        raise Teabag::Failure if Teabag.configuration.fail_fast
      end

      # Exceptions come from startup errors in the server
      def exception(exception = {})
        raise Teabag::RunnerException
      end

      def suppress_logs?
        false
      end

      private

      def log_coverage(data)
        return if data.blank? || suppress_logs?
        STDOUT.print(Teabag::Coverage.new(data).reports)
      end
    end
  end
end
