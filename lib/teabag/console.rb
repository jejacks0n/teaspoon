require "teabag/server"
require "teabag/runner"
require "phantomjs"

module Teabag
  class Console

    def initialize(suite_name = nil)
      # force asset debugging off -- gives us nicer errors on missing files, bad coffeescript, etc
      Rails.application.config.assets.debug = false

      if suite_name
        @suites = [suite_name]
      else
        @suites = Teabag.configuration.suites.keys
      end
    end

    def execute
      STDOUT.print "Starting server...\n"
      start_server
      failure_count = 0
      @suites.each do |suite|
        STDOUT.print "Teabag running #{suite} suite at #{url(suite)}...\n"
        failure_count += run_specs(suite)
      end
      failure_count > 0
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
      runner = Teabag::Runner.new(suite)
      Phantomjs.run(script, url(suite)) do |line|
        runner.process(line)
      end
      runner.failure_count
    end

    protected

    def script
      File.expand_path("../phantomjs/runner.coffee", __FILE__)
    end

    def url(suite)
      ["#{@server.url}#{Teabag.configuration.mount_at}", suite].join("/")
    end
  end
end
