# encoding: utf-8

module Teaspoon
  module Formatters
    class SnowdayFormatter < DotFormatter

      protected

      def log_spec(result)
        return log_str("☃", CYAN) if result.passing?
        return log_str("☹", YELLOW) if result.pending?
        log_str("☠", RED)
      end
    end
  end
end
