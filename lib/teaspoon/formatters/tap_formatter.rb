module Teaspoon
  module Formatters
    class TapFormatter < Base

      protected

      def log_runner(result)
        log_line("1..#{@total_count}")
      end

      def log_passing_spec(result)
        log_line("ok #{@run_count} - #{result.description}")
      end

      def log_pending_spec(result)
        log_line("ok #{@run_count} - [pending] #{result.description}")
      end

      def log_failing_spec(result)
        log_line("not ok #{@run_count} - #{result.description}")
        log_line("  FAIL #{result.message}")
      end

      def log_console(message)
        log_line("# #{message.gsub(/\n$/, "")}")
      end

      def log_coverage(message)
        log_line("# #{message.gsub(/\n/, "\n# ")}")
      end

      def log_threshold_failure(message)
        log_line("not ok #{@run_count + 1} - Coverage threshold failed")
        log_line("# #{message.gsub(/\n/, "\n# ")}")
      end
    end
  end
end
