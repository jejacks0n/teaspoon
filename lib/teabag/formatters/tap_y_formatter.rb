require 'teabag/formatters/base_formatter'
require 'yaml'

module Teabag
  module Formatters
    class TapYFormatter < BaseFormatter

      def runner(result)
        log "type"  => "suite",
            "start" => result.start,
            "count" => result.total,
            "seed"  => 0,
            "rev"   => 4
      end

      def suite(result)
        log "type"  => "case",
            "label" => result.label,
            "level" => result.level
      end

      def spec(result)
        super
        @result = result
        return passing_spec if result.passing?
        return pending_spec if result.pending?
        failing_spec
      end

      def result(result)
        log "type" => "final",
            "time" => result.elapsed,
            "counts" => {
              "total" => @total,
              "pass"  => @passes.size,
              "fail"  => @failures.size,
              "error" => @errors.size,
              "omit"  => 0,
              "todo"  => @pendings.size
            }
      end

      def error(error)
        @errors << error
      end

      private

      def passing_spec
        log "type"   => "test",
            "status" => "pass",
            "label"  => @result.label
      end

      def pending_spec
        log "type"   => "test",
            "status" => "pending",
            "label"  => @result.label,
            "exception" => {
              "message"   => @result.message
            }
      end

      def failing_spec
        log "type"   => "test",
            "status" => "fail",
            "label"  => @result.label,
            "exception" => {
              "message"   => @result.message,
              "backtrace" => ["#{@result.link}#:0"],
              "file"      => "unknown",
              "line"      => "unknown",
              "source"    => "unknown",
              "snippet"   => {"0" => @result.link},
              "class"     => "Unknown"
            }
      end

      def log(hash)
        STDOUT.print(hash.to_yaml)
      end

    end
  end
end
