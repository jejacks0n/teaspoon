require "teabag/server"
require "teabag/formatter"
require "phantomjs"

class Teabag::Console

  def initialize(suite_name = nil)
    # force asset debugging to false, which gives us much nicer errors
    #Rails.application.config.assets.debug = false

    if suite_name
      @suites = [suite_name]
    else
      @suites = Teabag.configuration.suites.keys
    end
  end

  def execute
    STDOUT.print "Starting server...\n"
    start_server
    failures = 0
    @suites.each do |suite|
      STDOUT.print "Teabag running #{suite} suite at #{url(suite)}...\n"
      failures += run_specs(suite)
    end
    failures > 0
  rescue Teabag::Failure
    true
  rescue Teabag::RunnerException
    true
  end

  def start_server
    @server = Teabag::Server.new
    @server.start
  end

  def run_specs(suite)
    formatter = Teabag::Formatter.new(suite)
    Phantomjs.run(script, url(suite)) do |line|
      formatter.process(line)
    end
    formatter.failures
  end

  protected

  def script
    File.expand_path("../phantomjs/runner.coffee", __FILE__)
  end

  def url(suite)
    ["#{@server.url}#{Teabag.configuration.mount_at}", suite].join("/")
  end
end
