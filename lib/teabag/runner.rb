require "json"

class Teabag::Runner

  attr_accessor :formatters
  attr_reader   :failure_count

  def initialize(suite_name = :default, default_formatter = Teabag::Formatters::ProgressFormatter.new)
    @suite_name = suite_name
    @formatters = [ default_formatter ]
    @failure_count = 0
  end

  def process(line)
    return if output_from(line)
    log line unless Teabag.configuration.suppress_log
  end

  private

  def output_from(line)
    json = JSON.parse(line)
    return false unless json["_teabag"] && json["type"]
    notify_formatters json["type"], json
    @failure_count += 1 if is_failure?(json)
    return true
  rescue JSON::ParserError
    false
  end

  private

  def is_failure?(spec)
    (spec['status'] != 'passed' && spec['status'] != 'pending') || spec['type'] == 'exception' || spec['type'] == 'error'
  end

  def notify_formatters(event, data)
    @formatters.each do |formatter|
      formatter.send(event, data) if formatter.respond_to?(event)
    end
  end

end
