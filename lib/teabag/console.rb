require 'open-uri'
require 'teabag/environment'

module Teabag
  class Console

    def initialize(options = nil, files = [])
      @options = options || {}
      @files = files

      Teabag::Environment.load(@options)
      require "teabag/server"
      Rails.application.config.assets.debug = false if Teabag.configuration.driver == 'phantomjs'

      if @options[:suite].present?
        @suites = [@options[:suite]]
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

    def filter
      parts = []
      parts << "grep=#{URI::encode(@options[:filter])}" if @options[:filter].present?
      @files.each { |file| parts << "file[]=#{URI::encode(file)}" }
      "?#{parts.join('&')}" if parts.present?
    end

    def url(suite)
      ["#{@server.url}#{Teabag.configuration.mount_at}", suite, filter].compact.join("/")
    end
  end
end
