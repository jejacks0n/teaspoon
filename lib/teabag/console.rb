require "teabag/server"

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
      STDOUT.print "Starting server...\n" unless Teabag.configuration.suppress_log
      start_server
      failure_count = 0
      @suites.each do |suite|
        STDOUT.print "Teabag running #{suite} suite at #{url(suite)}...\n" unless Teabag.configuration.suppress_log
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
      driver.run_specs(suite, url(suite))
    end

    protected

    def driver
      @driver ||= Teabag::Drivers.const_get("#{Teabag.configuration.driver.to_s.camelize}Driver").new
    end

    def url(suite)
      ["#{@server.url}#{Teabag.configuration.mount_at}", suite].join("/")
    end
  end
end
