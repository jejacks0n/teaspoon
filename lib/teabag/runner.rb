require "json"
require "teabag/result"

module Teabag
  class Runner

    attr_accessor :formatters
    attr_reader   :failure_count

    def initialize(suite_name = :default)
      @suite_name = suite_name
      @formatters = Teabag.configuration.formatters.split(',').map {|f| resolve_formatter(f).new }
      @failure_count = 0
    end

    def process(line)
      return if output_from(line)
      log line unless Teabag.configuration.suppress_log
    end

    private

    def resolve_formatter(formatter)
      Teabag::Formatters.const_get("#{formatter.to_s.capitalize}Formatter")
    end

    def output_from(line)
      json = JSON.parse(line)
      return false unless json["_teabag"] && json["type"]
      result = Teabag::Result.build_from_json(@suite_name, json)
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
