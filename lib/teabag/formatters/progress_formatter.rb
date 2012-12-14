require 'teabag/formatters/base_formatter'

module Teabag
  module Formatters
    class ProgressFormatter < BaseFormatter

      RED = 31
      GREEN = 32
      YELLOW = 33
      CYAN = 36

      def spec(result)
        super
        if result.passing?
          log ".", GREEN
        elsif result.pending?
          log "*", YELLOW
        else
          log "F", RED
        end
      end

      # Errors are reported from the onError handler in Phantom, so they're not linked to a result
      def error(error)
        log "#{error["msg"]}\n", RED
        for trace in error["trace"] || []
          log "  # #{filename(trace["file"])}:#{trace["line"]}#{trace["function"].present? ? " -- #{trace["function"]}" : ""}\n", CYAN
        end
        log "\n"
      end

      def results(results)
        log "\n\n"
        pending_log if pendings.size > 0
        failure_log if failures.size > 0
        status(results)
        failed_examples if failures.size > 0
        raise Teabag::Failure if failures.size > 0 && Teabag.configuration.fail_fast
      end

      private

      def log(str, color_code = nil)
        STDOUT.print(color_code ? colorize(str, color_code) : str)
      end

      def colorize(str, color_code)
        "\e[#{color_code}m#{str}\e[0m"
      end

      def pluralize(str, value)
        value == 1 ? "#{value} #{str}" : "#{value} #{str}s"
      end

      def filename(file)
        file.gsub(%r(^http://127.0.0.1:\d+/assets/), "").gsub(/[\?|&]?body=1/, "")
      end

      def failure_log
        log "Failures:\n"
        failures.each_with_index do |failure, index|
          log "\n  #{index + 1}) #{failure["spec"]}\n"
          log "     Failure/Error: #{failure["message"]}\n", RED
        end
        log "\n"
      end

      def failed_examples
        log "\nFailed examples:\n"
        failures.each do |failure|
          log "\n#{Teabag.configuration.mount_at}/#{failure.teabag_suite}#{failure.link}", RED
        end
        log "\n\n"
      end

      def pending_log
        log "Pending:"
        pendings.each do |result|
          log "\n  #{result.spec}\n", YELLOW
          log "    # Not yet implemented\n", CYAN
        end
        log "\n"
      end

      def status(results)
        log "Finished in #{results["elapsed"]} seconds\n"
        stats = "#{pluralize("example", total)}, #{pluralize("failure", failures.size)}"
        stats << ", #{pendings.size} pending" if pendings.size > 0
        log "#{stats}\n", failures.size > 0 ? RED : pendings.size > 0 ? YELLOW : GREEN
      end

    end
  end
end
