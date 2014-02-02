require "yaml"

module Teaspoon
  module Formatters
    class TapYFormatter < Base

      protected

      def log_runner(result)
        log "type"  => "suite",
            "start" => result.start,
            "count" => result.total,
            "seed"  => 0,
            "rev"   => 4
      end

      def log_suite(result)
        log "type"  => "case",
            "label" => result.label,
            "level" => result.level
      end

      def log_passing_spec(result)
        log "type"   => "test",
            "status" => "pass",
            "label"  => result.label,
            "stdout" => @stdout
      end

      def log_pending_spec(result)
        log "type"   => "test",
            "status" => "pending",
            "label"  => result.label,
            "stdout" => @stdout,
            "exception" => {
              "message" => result.message
            }
      end

      def log_failing_spec(result)
        log "type"   => "test",
            "status" => "fail",
            "label"  => result.label,
            "stdout" => @stdout,
            "exception" => {
              "message"   => result.message,
              "backtrace" => ["#{result.link}#:0"],
              "file"      => "unknown",
              "line"      => "unknown",
              "source"    => "unknown",
              "snippet"   => {"0" => result.link},
              "class"     => "Unknown"
            }
      end

      def log_result(result)
        log "type" => "final",
            "time" => result.elapsed,
            "counts" => {
              "total" => @run_count,
              "pass"  => @passes.size,
              "fail"  => @failures.size,
              "error" => @errors.size,
              "omit"  => 0,
              "todo"  => @pendings.size
            }
      end

      private

      def log(hash)
        log_str(hash.to_yaml)
      end
    end
  end
end
