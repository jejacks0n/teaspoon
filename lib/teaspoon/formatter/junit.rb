require "teaspoon/formatter/base"
require "cgi"

module Teaspoon
  module Formatter
    class Junit < Base
      protected

        def log_runner(result)
          log_line(%{<?xml version="1.0" encoding="UTF-8"?>})
          log_line(%{<testsuites name="Teaspoon">})
          start_time = Time.parse(result.start).iso8601
          log_line(%{<testsuite name="#{escape(@suite_name)}" tests="#{@total_count}" timestamp="#{start_time}">})
        end

        def log_suite(result)
          log_end_suite
          log_line(%{<testsuite name="#{escape(result.label)}">})
        end

        def log_passing_spec(result)
          log_junit_spec(suite: result.suite, label: result.label)
        end

        def log_pending_spec(result)
          log_junit_spec(suite: result.suite, label: result.label) do
            log_line(%{  <skipped/>})
          end
        end

        def log_failing_spec(result)
          log_junit_spec(suite: result.suite, label: result.label) do
            log_line(%{  <failure type="AssertionFailed">#{cdata(result.message)}</failure>})
          end
        end

        def log_result(_result)
          log_end_suite
        end

        def log_coverage(message)
          properties = "<properties>#{cdata(message)}</properties>"
          log_line(%{<testsuite name="Coverage summary" tests="0">\n#{properties}\n</testsuite>})
        end

        def log_threshold_failure(message)
          log_line(%{<testsuite name="Coverage thresholds" tests="1">})
          log_junit_spec(suite: "Coverage thresholds", label: "were not met") do
            log_line(%{  <failure type="AssertionFailed">#{cdata(message)}</failure>})
          end
          log_line(%{</testsuite>})
        end

        def log_complete(_failure_count)
          log_line(%{</testsuite>\n</testsuites>})
        end

      private

        def log_end_suite
          log_line(%{</testsuite>}) if @last_suite
        end

        def log_junit_spec(opts, &_block)
          log_line(%{<testcase classname="#{escape(opts[:suite])}" name="#{escape(opts[:label])}">})
          yield if block_given?
          log_line(%{<system-out>#{cdata(@stdout)}</system-out>}) unless @stdout.blank?
          log_line(%{</testcase>})
        end

        def escape(str)
          CGI.escapeHTML(str)
        end

        def cdata(str)
          "\n<![CDATA[\n#{str.gsub(/\n$/, '')}\n]]>\n"
        end
    end
  end
end
