require 'teaspoon/formatters/base_formatter'

module Teaspoon
  module Formatters
    class TeamcityFormatter < BaseFormatter
      def runner(result)
        log "##teamcity[testSuiteStarted name='Jasmine']"
      end

      def spec(result)
        log "##teamcity[testStarted name='#{escape result.description}' captureStandardOutput='false']"

        unless result.passing? || result.pending?
          log "##teamcity[testFailed name='#{escape result.description}' message='#{escape result.message}']"
        end

        log "##teamcity[testFinished name='#{escape result.description}']"
      end

      def error(error)
        log "##teamcity[message text='#{escape error.message}' errorDetails='#{escape format_trace(error.trace)}' status='ERROR']"
      end

      def result(result)
        log "##teamcity[testSuiteFinished name='Jasmine']"
      end

      def suppress_logs?
        true
      end

      private
      def log(str)
        STDOUT.print("#{str}\n")
      end

      def escape(str)
        {
          /\|/m => "||",
          /'/m => "|'",
          /\n/m => "|n",
          /\r/m => "|r",
          /\[/m => "|[",
          /\]/m => "|]",
        }.inject(str) do |result, (regex, sub)|
          result.gsub(regex, sub)
        end
      end

      def format_trace(trace)
        trace.map { |line|
          ["#{line['file']}:#{line['line']}", line['function']].compact.join(' ')
        }.join("\n")
      end
    end
  end
end
