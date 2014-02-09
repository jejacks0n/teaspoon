require "json"
require "teaspoon/result"

module Teaspoon
  class Runner

    attr_reader :failure_count

    def initialize(suite_name = :default)
      @suite_name = suite_name
      @failure_count = 0
      @formatters = Teaspoon.configuration.formatters.map{ |f| resolve_formatter(f) }
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
      formatter = Teaspoon::Formatters.const_get("#{formatter.camelize}Formatter")
      formatter.new(@suite_name, output)
    rescue NameError
      raise Teaspoon::UnknownFormatter, "Unknown formatter: \"#{formatter}\""
    end

    def notify_formatters(event, result)
      @formatters.each { |f| f.send(event, result) if f.respond_to?(event) }
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
  end
end
