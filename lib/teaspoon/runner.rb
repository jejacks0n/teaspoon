require "json"
require "teaspoon/result"

module Teaspoon
  class Runner

    attr_accessor :formatters
    attr_reader   :failure_count

    def initialize(suite_name = :default)
      @suite_name = suite_name
      @formatters = Teaspoon.configuration.formatters.map{ |f| resolve_formatter(f).new(suite_name) }
      @failure_count = 0
    end

    def suppress_logs?
      return @suppress_logs unless @suppress_logs.nil?
      @suppress_logs = Teaspoon.configuration.suppress_log
      return true if @suppress_logs
      for formatter in @formatters
        return @suppress_logs = true if formatter.suppress_logs?
      end
      @suppress_logs = false
    end

    def process(line)
      return if output_from(line)
      log line unless suppress_logs?
    end

    private

    def resolve_formatter(formatter)
      Teaspoon::Formatters.const_get("#{formatter.to_s.camelize}Formatter")
    end

    def output_from(line)
      json = JSON.parse(line)
      return false unless json["_teaspoon"] && json["type"]
      result = Teaspoon::Result.build_from_json(json)
      notify_formatters result
      @failure_count += 1 if result.failing?
      return true
    rescue JSON::ParserError
      false
    end

    def notify_formatters(result)
      @formatters.each do |formatter|
        event = result.type
        formatter.send(event, result) if formatter.respond_to?(event)
      end
    end

    def log(msg)
      STDOUT.print msg
    end
  end
end
