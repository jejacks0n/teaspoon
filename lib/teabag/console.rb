require "teabag/server"
require "teabag/formatter"
require "phantomjs"
require "phantomjs-mac" # todo: the phantom stuff in here should get factored into the phantomjs.rb gem

class Teabag::Console

  def initialize(suite_name)
    @suite_name = suite_name
  end

  def execute
    start_server
    run_specs
  end

  def start_server
    @server = Teabag::Server.new
    @server.start
  end

  def run_specs
    @formatter = Teabag::Formatter.new(@suite_name)
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
