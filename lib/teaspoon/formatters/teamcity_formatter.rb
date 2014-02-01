require 'teaspoon/formatters/base_formatter'

module Teaspoon
  module Formatters
    class TeamcityFormatter < BaseFormatter

      def runner(result)
        log "##teamcity[testSuiteStarted name='#{@suite_name}']"
      end

      def spec(result)
        log "##teamcity[testStarted name='#{escape(result.description)}' captureStandardOutput='false']"

        unless result.passing? || result.pending?
          log "##teamcity[testFailed name='#{escape(result.description)}' message='#{escape(result.message)}']"
        end

        log "##teamcity[testFinished name='#{escape(result.description)}']"
      end

      def error(error)
        log "##teamcity[message text='#{escape(error.message)}' errorDetails='#{escape_trace(error.trace)}' status='ERROR']"
      end

      def result(result)
        log "##teamcity[testSuiteFinished name='Jasmine']"
      end

      def suppress_logs?
        true
      end

      private

      def escape(str)
        str.gsub(/[|'\[\]\n\r]/) { |c| "|#{c}" }
      end

      def escape_trace(trace)
        lines = trace.map { |t| ["#{t["file"]}:#{t["line"]}", t["function"]].compact.join(" ") }
        escape(lines.join("\n"))
      end
    end
  end
end
