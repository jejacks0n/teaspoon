require "json"

class Teabag::Formatter

  RED = 31
  GREEN = 32
  YELLOW = 33
  CYAN = 36

  def initialize(suite_name = :default)
    @suite_name = suite_name
  end

  def process(line)
    return if output_from(line)
    log line
  end

  def spec(spec)
    case spec["status"]
      when "pass" then log ".", GREEN
      when "skipped" then log "*", YELLOW
      else log "F", RED
    end
  end

  def error(error)
    log "#{error["msg"]}\n", RED
    for trace in error["trace"] || []
      log "  # #{filename(trace["file"])}:#{trace["line"]}#{trace["function"].present? ? " -- #{trace["function"]}" : ""}\n", CYAN
    end
    log "\n"
  end

  def results(results)
    fails = results["failures"].length
    pending = results["pending"].length

    log "\n\n"
    pending(results["pending"]) if pending > 0
    failures(results["failures"]) if fails > 0
    status(results, fails, pending)
    failed_examples(results["failures"]) if fails > 0
    raise Teabag::Failure if fails > 0
  end

  protected

  def status(results, fails, pending)
    log "Finished in #{results["elapsed"]} seconds\n"
    stats = "#{pluralize("example", results["total"])}, #{pluralize("failure", fails)}"
    stats << ", #{pending} pending" if pending > 0
    log "#{stats}\n", fails > 0 ? RED : pending > 0 ? YELLOW : GREEN
  end

  def failures(failures)
    log "Failures:\n"
    failures.each_with_index do |failure, index|
      log "\n  #{index + 1}) #{failure["spec"]}\n"
      log "     Failure/Error: #{failure["description"]}\n", RED
      #log "    # #{failure['trace']}\n", CYAN
    end
    log "\n"
  end

  def pending(pending)
    log "Pending:"
    pending.each do |pending|
      log "\n  #{pending["spec"]}\n", YELLOW
      log "    # Not yet implemented\n", CYAN
    end
    log "\n"
  end

  def failed_examples(failures)
    log "\nFailed examples:\n"
    failures.each do |failure|
      log "\n#{Teabag.configuration.mount_at}/#{@suite_name}#{failure["link"]}", RED
    end
    log "\n\n"
  end

  def output_from(line)
    json = JSON.parse(line)
    return false unless json["_teabag"] && json["type"]
    case json["type"]
      when "spec" then spec(json)
      when "error" then error(json)
      when "results" then results(json)
    end
    return true
  rescue JSON::ParserError => e
    false
  end

  def pluralize(str, value)
    value == 1 ? "#{value} #{str}" : "#{value} #{str}s"
  end

  def filename(file)
    file.gsub(%r(^http://127.0.0.1:\d+/assets/), "").gsub(/[\?|&]?body=1/, "")
  end

  def log(str, color_code = nil)
    STDOUT.print(color_code ? colorize(str, color_code) : str)
  end

  def colorize(str, color_code)
    "\e[#{color_code}m#{str}\e[0m"
  end
end
