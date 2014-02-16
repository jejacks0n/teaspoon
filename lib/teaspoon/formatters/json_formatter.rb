module Teaspoon
  module Formatters
    class JsonFormatter < Base

      protected

      def log_runner(result)
        log_result(result)
      end

      def log_suite(result)
        log_result(result)
      end

      def log_spec(result)
        log_result(result)
      end

      def log_error(result)
        log_result(result)
      end

      def log_exception(result)
        log_result(result)
      end

      def log_console(message)
        log_line(%Q{{"type":"console","log":"#{message.gsub(/\n$/, "").gsub("\n", "\\n")}"}})
      end

      def log_result(result)
        log_str(result.original_json)
      end
    end
  end
end
