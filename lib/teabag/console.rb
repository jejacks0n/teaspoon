require "teabag/server"
require "teabag/formatter"
require "phantomjs"
require "phantomjs-mac" # todo: the phantom stuff in here should get factored into the phantomjs.rb gem

class Teabag::Console

  def initialize(suite_name = nil)
    if suite_name
      @suites = [suite_name]
    else
      @suites = Teabag.configuration.suites.keys
    end
  end

  def execute
    start_server
    @suites.each do |suite|
      run_specs(suite)
    end
    false
  rescue Teabag::Failure
    true
  end

  def start_server
    @server = Teabag::Server.new
    @server.start
  end

  def run_specs(suite)
    STDOUT.print "Teabag starting for: #{suite}...\n"
    @formatter = Teabag::Formatter.new(suite)
    IO.popen("#{Phantomjs.executable_path} #{script} #{url(suite)}").each_line do |line|
      @formatter.process(line)
    end
  end

  protected

  def script
    File.expand_path("../phantomjs/runner.coffee", __FILE__)
  end

  def url(suite)
    ["#{@server.url}#{Teabag.configuration.mount_at}", suite].join("/")
  end
end
