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
      @suite_name = suite
      run_specs
    end
  end

  def start_server
    @server = Teabag::Server.new
    @server.start
  end

  def run_specs
    STDOUT.print "Teabag starting for: #{@suite_name}...\n"
    @formatter = Teabag::Formatter.new
    IO.popen("#{Phantomjs.executable_path} #{script} #{url}").each_line do |line|
      @formatter.process(line)
    end
    return 0
  rescue Teabag::Failure
    return 1
  end

  protected

  def script
    File.expand_path("../phantomjs/runner.coffee", __FILE__)
  end

  def url
    ["#{@server.url}#{Teabag.configuration.mount_at}", @suite_name].join("/")
  end
end
