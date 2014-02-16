module Teaspoon
  module Formatters
    class TeamcityFormatter < Base

      def initialize(*args)
        log("enteredTheMatrix timestamp='#{Time.now.to_json.gsub('"', "")}'")
        super
      end

      protected

      def log_runner(result)
        log("testCount count='#{result.total}' timestamp='#{result.start}'")
      end

      def log_suite(result)
        log_end_suite
        log("testSuiteStarted name='#{result.label}'")
      end

      def log_passing_spec(result)
        log_teamcity_spec(type: "testStarted", desc: escape(result.description))
      end

      def log_pending_spec(result)
        log_teamcity_spec(type: "testIgnored", desc: escape(result.description))
      end

      def log_failing_spec(result)
        log_teamcity_spec(type: "testStarted", desc: escape(result.description)) do
          log("testFailed name='#{escape(result.description)}' message='#{escape(result.message)}'")
        end
      end

      def log_error(result)
        log("message text='#{escape(result.message)}' errorDetails='#{escape_trace(result.trace)}' status='ERROR'")
      end

      def log_result(result)
        log_end_suite
        @result = result
      end

      def log_coverage(message)
        log("testSuiteStarted name='Coverage summary'")
        log_line(message)
        log("testSuiteFinished name='Coverage summary'")
      end

      def log_threshold_failure(message)
        log("testSuiteStarted name='Coverage thresholds'")
        log_teamcity_spec(type: "testStarted", desc: "Coverage thresholds") do
          log("testFailed name='Coverage thresholds' message='were not met'")
          log_line(message)
        end
        log("testSuiteFinished name='Coverage thresholds'")
      end

      def log_complete(failure_count)
        log_line("\nFinished in #{@result.elapsed} seconds")
        stats = "#{pluralize("example", run_count)}, #{pluralize("failure", failure_count)}"
        stats << ", #{pendings.size} pending" if pendings.size > 0
        log_line(stats)
        log_line if failure_count > 0
      end

      private

      def log_end_suite
        log("testSuiteFinished name='#{escape(@last_suite.label)}'") if @last_suite
      end

      def log_teamcity_spec(opts, &block)
        log("#{opts[:type]} name='#{opts[:desc]}' captureStandardOutput='true'")
        log_line(@stdout.gsub(/\n$/, "")) unless @stdout.blank?
        yield if block_given?
        log("testFinished name='#{opts[:desc]}'")
      end

      def log(str)
        log_line("##teamcity[#{str}]")
      end

      def escape(str)
        str = str.gsub(/[|'\[\]]/) { |c| "|#{c}" }
        str.gsub("\n", "|n").gsub("\r", "|r")
      end

      def escape_trace(trace)
        lines = trace.map { |t| ["#{t["file"]}:#{t["line"]}", t["function"]].compact.join(" ") }
        escape(lines.join("\n"))
      end
    end
  end
end
