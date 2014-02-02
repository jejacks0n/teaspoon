require "cgi"

module Teaspoon
  module Formatters
    class JunitFormatter < Base

      protected

      def log_runner(result)
        log_line(%Q{<?xml version="1.0" encoding="UTF-8"?>})
        log_line(%Q{<testsuites name="Teaspoon">})
        log_line(%Q{<testsuite name="#{@suite_name}" tests="#{@total_count}" time="#{result.start}">})
      end

      def log_suite(result)
        log_end_suite
        log_line(%Q{<testsuite name="#{result.label}">})
      end

      def log_passing_spec(result)
        log_teamcity_spec(suite: result.suite, label: result.label)
      end

      def log_pending_spec(result)
        log_teamcity_spec(suite: result.suite, label: result.label) do
          log_line(%Q{  <skipped/>})
        end
      end

      def log_failing_spec(result)
        log_teamcity_spec(suite: result.suite, label: result.label) do
          log_line(%Q{  <failure type="AssertionFailed">#{cdata(result.message)}</failure>})
        end
      end

      def log_result(result)
        log_end_suite
        log_line(%Q{</testsuite>\n</testsuites>})
      end

      private

      def log_end_suite
        log_line(%Q{</testsuite>}) if @last_suite
      end

      def log_teamcity_spec(opts, &block)
        log_line(%Q{<testcase classname="#{escape(opts[:suite])}" name="#{escape(opts[:label])}">})
        yield if block_given?
        log_line(%Q{<system-out>#{cdata(@stdout)}</system-out>}) unless @stdout.blank?
        log_line(%Q{</testcase>})
      end

      def escape(str)
        CGI::escapeHTML(str)
      end

      def escape_trace(trace)
        lines = trace.map { |t| ["#{t["file"]}:#{t["line"]}", t["function"]].compact.join(" ") }
        escape(lines.join("\n"))
      end

      def cdata(str)
        "\n<![CDATA[\n#{str.gsub(/\n$/, "")}\n]]>\n"
      end
    end
  end
end
