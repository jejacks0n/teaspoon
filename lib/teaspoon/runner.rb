require "json"
require "teaspoon/result"

module Teaspoon
  class Runner
    attr_reader :failure_count

    def initialize(suite_name = :default)
      @suite_name = suite_name
      @failure_count = 0
      @formatters = Teaspoon.configuration.formatters.map { |f| resolve_formatter(f) }
    end

    def process(line)
      if result = result_from_line(line)
        return notify_formatters(result.type, result)
      end
      notify_formatters("console", line) unless Teaspoon.configuration.suppress_log
    end

    private

    def resolve_formatter(formatter)
      formatter, output = formatter.to_s.split(">")
      Teaspoon::Formatter.fetch(formatter).new(@suite_name, output)
    end

    def notify_formatters(event, result)
      @formatters.each { |f| f.send(event, result) if f.respond_to?(event) }
      send(:"on_#{event}", result) if respond_to?(:"on_#{event}", true)
    end

    def result_from_line(line)
      json = JSON.parse(line)
      return false unless json && json["_teaspoon"] && json["type"]
      json["original_json"] = line
      return result_from_json(json)
    rescue JSON::ParserError
      false
    end

    def result_from_json(json)
      result = Teaspoon::Result.build_from_json(json)
      @failure_count += 1 if result.failing?
      result
    end

    def on_exception(result)
      raise Teaspoon::RunnerError.new(result.message)
    end

    def on_result(result)
      resolve_coverage(result.coverage)
      notify_formatters("complete", @failure_count)
    end

    def resolve_coverage(data)
      return unless Teaspoon.configuration.use_coverage
      raise Teaspoon::IstanbulNotFoundError unless Teaspoon::Instrumentation.executable
      return unless data.present?

      coverage = Teaspoon::Coverage.new(@suite_name, data)
      coverage.generate_reports { |msg| notify_formatters("coverage", msg) }
      coverage.check_thresholds do |msg|
        notify_formatters("threshold_failure", msg)
        @failure_count += 1
      end
    end
  end
end
