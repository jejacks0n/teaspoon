require 'teaspoon/formatters/base_formatter'

module Teaspoon
  module Formatters
    class JunitFormatter < BaseFormatter

      def runner(result)
        @count = result.total

        log <<-XML.strip_heredoc.gsub(/\n$/, '')
          <?xml version="1.0" encoding="UTF-8"?>
          <testsuites name="Teaspoon">
            <testsuite name="#{@suite_name}" tests="#{@count}">
        XML
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

      def result(result)
        log <<-XML.strip_heredoc
            </testsuite>
          </testsuites>
        XML
      end

      def suppress_logs?
        false
      end

      private

      def passing_spec
        log %Q{    <testcase classname="#{@result.suite}" name="#{@result.label}"></testcase>}
      end

      def pending_spec
        log %Q{    <testcase classname="#{@result.suite}" name="#{@result.label}"><skipped /></testcase>}
      end

      def failing_spec
        log <<-XML.strip_heredoc.gsub(/\n$/, '')
              <testcase classname="#{@result.suite}" name="#{@result.label}">
                <failure type="AssertionFailed">#{@result.message}</failure>
              </testcase>
        XML
      end
    end
  end
end
