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
        log_junit_spec(suite: result.suite, label: result.label)
      end

      def log_pending_spec(result)
        log_junit_spec(suite: result.suite, label: result.label) do
          log_line(%Q{  <skipped/>})
        end
      end

      def log_failing_spec(result)
        log_junit_spec(suite: result.suite, label: result.label) do
          log_line(%Q{  <failure type="AssertionFailed">#{cdata(result.message)}</failure>})
        end
      end

      def log_result(result)
        log_end_suite
      end

      def log_coverage(message)
        log_line(%Q{<testsuite name="Coverage summary" tests="0">\n<properties>#{cdata(message)}<properties>\n</testsuite>})
      end

      def log_threshold_failure(message)
        log_line(%Q{<testsuite name="Coverage thresholds" tests="1">})
        log_junit_spec(suite: "Coverage thresholds", label: "were not met") do
          log_line(%Q{  <failure type="AssertionFailed">#{cdata(message)}</failure>})
        end
        log_line(%Q{</testsuite>})
      end

      def log_complete(failure_count)
        log_line(%Q{</testsuite>\n</testsuites>})
      end

      private

      def log_end_suite
        log_line(%Q{</testsuite>}) if @last_suite
      end

      def log_junit_spec(opts, &block)
        log_line(%Q{<testcase classname="#{escape(opts[:suite])}" name="#{escape(opts[:label])}">})
        yield if block_given?
        log_line(%Q{<system-out>#{cdata(@stdout)}</system-out>}) unless @stdout.blank?
        log_line(%Q{</testcase>})
      end

      def escape(str)
        CGI::escapeHTML(str)
      end

      def cdata(str)
        "\n<![CDATA[\n#{str.gsub(/\n$/, "")}\n]]>\n"
      end
    end
  end
end
