require 'teaspoon/formatters/base_formatter'

module Teaspoon
  module Formatters
    class TapFormatter < BaseFormatter

      def runner(result)
        log "1..#{result.total}"
      end

      def spec(result)
        super
        @result = result
        return passing_spec if result.passing?
        return pending_spec if result.pending?
        failing_spec
      end

      def error(error)
        @errors << error
      end

      def suppress_logs?
        true
      end

      private

      def passing_spec
        log "ok #{@total} - #{@result.description}"
      end

      def pending_spec
        log "ok #{@total} - [pending] #{@result.description}"
      end

      def failing_spec
        log "not ok #{@total} - #{@result.description}\n  # FAIL #{@result.message}"
      end

      def log(str)
        STDOUT.print("#{str}\n")
      end

    end
  end
end
