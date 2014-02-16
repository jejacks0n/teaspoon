require "teaspoon/formatters/modules/report_module"

module Teaspoon
  module Formatters
    class DocumentationFormatter < Base
      include ReportModule

      protected

      def initialize(*args)
        @level = 0
        super
      end

      def log_suite(result)
        log_indent_line(result.label, result.level)
        @level = result.level
      end

      def log_passing_spec(result)
        log_indent_spec(result.label, GREEN)
      end

      def log_pending_spec(result)
        log_indent_spec("#{result.label} (PENDING)", YELLOW)
      end

      def log_failing_spec(result)
        log_indent_spec("#{result.label} (FAILED - #{@failures.length})", RED)
      end

      def log_result(result)
        log_line
        super
      end

      private

      def log_indent_spec(str, color)
        log_indent_line(str, level = (@last_suite ? @level + 1 : 0), color)
        log_intent_stdout(level + 1)
      end

      def log_intent_stdout(level)
        return if @stdout.blank?
        log_indent_line("# #{@stdout.gsub(/\n$/, "").gsub("\n", "\n# ")}", level, CYAN)
      end

      def log_indent_line(str = "", level = nil, color = nil)
        log_line(indent(str, level || @level), color)
      end

      def indent(str = "", level = nil)
        indent = "#{"  " * level}"
        str.gsub!("\n", "\n#{indent}")
        "#{indent}#{str}"
      end
    end
  end
end
