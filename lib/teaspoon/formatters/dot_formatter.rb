require 'teaspoon/formatters/base_formatter'

module Teaspoon
  module Formatters
    class DotFormatter < BaseFormatter

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
        log "#{error["message"]}\n", RED
        for trace in error["trace"] || []
          log "  # #{filename(trace["file"])}:#{trace["line"]}#{trace["function"].present? ? " -- #{trace["function"]}" : ""}\n", CYAN
        end
        log "\n"
      end

      def result(results)
        log "\n\n"
        log_information
        log_stats(results)
        log_failed_examples
        super
      end

      protected

      def log_information
        log_pending if pendings.size > 0
        log_failures if failures.size > 0
      end

      def log_pending
        log "Pending:\n"
        pendings.each do |result|
          log "  #{result.description}\n", YELLOW
          log "    # Not yet implemented\n\n", CYAN
        end
      end

      def log_failures
        log "Failures:\n\n"
        failures.each_with_index do |failure, index|
          log "  #{index + 1}) #{failure.description}\n"
          log "     Failure/Error: #{failure.message}\n\n", RED
        end
      end

      def log_stats(results)
        log "Finished in #{results["elapsed"]} seconds\n"
        stats = "#{pluralize("example", total)}, #{pluralize("failure", failures.size)}"
        stats << ", #{pendings.size} pending" if pendings.size > 0
        log "#{stats}\n", stats_color
        log "\n" unless failures.size == 0
      end

      def log_failed_examples
        return if failures.size == 0
        log "Failed examples:\n\n"
        failures.each do |failure|
          log "teaspoon -s #{@suite_name} --filter=\"#{failure.link}\"\n", RED
        end
      end

      private

      def log(str, color_code = nil)
        STDOUT.print(color_code ? colorize(str, color_code) : str)
      end

      def colorize(str, color_code)
        return str unless Teaspoon.configuration.color
        "\e[#{color_code}m#{str}\e[0m"
      end

      def pluralize(str, value)
        value == 1 ? "#{value} #{str}" : "#{value} #{str}s"
      end

      def stats_color
        failures.size > 0 ? RED : pendings.size > 0 ? YELLOW : GREEN
      end

      def filename(file)
        file.gsub(%r(^http://127.0.0.1:\d+/assets/), "").gsub(/[\?|&]?body=1/, "")
      end
    end
  end
end
