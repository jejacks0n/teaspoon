require "teaspoon/formatters/modules/report_module"

module Teaspoon
  module Formatters
    class DotFormatter < Base
      include ReportModule

      protected

      def log_spec(result)
        return log_str(".", GREEN) if result.passing?
        return log_str("*", YELLOW) if result.pending?
        log_str("F", RED)
      end

      def log_console(message)
        log_str(message)
      end

      def log_result(result)
        log_line("\n")
        super
      end
    end
  end
end
