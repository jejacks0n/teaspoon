require 'open-uri'
require 'teabag/environment'

module Teabag
  class Console

    def initialize(options = nil, files = [])
      @options = options || {}
      @suites = {}
      @files = []

      Teabag::Environment.load(@options)
      Rails.application.config.assets.debug = false if Teabag.configuration.driver == "phantomjs"

      start_server
      resolve(files)
    end

    def execute(options = {}, files = [])
      @options = @options.merge(options) if options.present?
      resolve(files)

      failure_count = 0
      suites.each do |suite|
        STDOUT.print "Teabag running #{suite} suite at #{url(suite)}\n" unless Teabag.configuration.suppress_log
        failure_count += run_specs(suite, @options[:driver_cli_options] || Teabag.configuration.driver_cli_options)
      end
      failure_count > 0
    rescue Teabag::Failure
      true
    rescue Teabag::RunnerException
      true
    end

    def run_specs(suite, driver_cli_options = "")
      url = url(suite)
      url += url.include?("?") ? "&" : "?"
      url += "reporter=Console"
      driver.run_specs(suite, url, driver_cli_options)
    end

    protected

    def resolve(files)
      return if files.length == 0
      @suites = {}
      @files = files
      files.uniq.each do |path|
        if result = Teabag::Suite.resolve_spec_for(path)
          suite = @suites[result[:suite]] ||= []
          suite << result[:path]
        end
      end
    end

    def start_server
      @server = Teabag::Server.new
      @server.start
    end

    def suites
      return [@options[:suite]] if @options[:suite].present?
      return @suites.keys if @suites.present?
      Teabag.configuration.suites.keys
    end

    def driver
      @driver ||= Teabag::Drivers.const_get("#{Teabag.configuration.driver.to_s.camelize}Driver").new
    end

    def filter(suite)
      parts = []
      parts << "grep=#{URI::encode(@options[:filter])}" if @options[:filter].present?
      (@suites[suite] || @files).each { |file| parts << "file[]=#{URI::encode(file)}" }
      "?#{parts.join('&')}" if parts.present?
    end

    def url(suite)
      ["#{@server.url}#{Teabag.configuration.mount_at}", suite, filter(suite)].compact.join("/")
    end
  end
end
