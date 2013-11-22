require 'teaspoon/formatters/base_formatter'

module Teaspoon
  module Formatters
    class JunitFormatter < BaseFormatter

      def runner(result)
        @count = result.total;

        log "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        log "<testsuites name=\"jasmine\"><testsuite name=\"#{result.suite}\" tests=\"#{@count}\">"
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
        log "</testsuite></testsuites>"
      end

      def suppress_logs?
        false
      end

      private

      def passing_spec
        log %Q[<testcase classname="#{@result.suite}" name="#{@result.label}"></testcase>\n]
      end

      def pending_spec
        log %Q[<testcase classname="#{@result.suite}" name="#{@result.label}"><skipped /></testcase>\n]
      end

      def failing_spec
        str = <<EOL;
<testcase classname="#{@result.suite}" name="#{@result.label}">
<failure type="AssertionFailed">#{@result.message}</failure>
</testcase>\n
EOL
        log str
      end

      def log(str)
        STDOUT.print("#{str}\n")
      end

    end
  end
end
