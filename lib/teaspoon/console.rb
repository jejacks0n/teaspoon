require 'open-uri'
require 'teaspoon/environment'

module Teaspoon
  class Console

    def initialize(options = nil, files = [])
      @options = options || {}
      @suites = {}
      @files = []

      Teaspoon::Environment.load(@options)

      start_server
      resolve(files)
    end

    def execute(options = {}, files = [])
      @options = @options.merge(options) if options.present?
      resolve(files)

      failure_count = 0
      suites.each do |suite|
        STDOUT.print "Teaspoon running #{suite} suite at #{url(suite)}\n" unless Teaspoon.configuration.suppress_log
        failure_count += run_specs(suite, @options[:driver_cli_options] || Teaspoon.configuration.driver_cli_options)
      end
      failure_count > 0
    rescue Teaspoon::Failure
      true
    rescue Teaspoon::RunnerException
      true
    end

    def run_specs(suite, driver_cli_options = nil)
      url = url(suite)
      url += url.include?("?") ? "&" : "?"
      url += "reporter=Console"
      driver.run_specs(suite, url, driver_cli_options, @options)
    end

    protected

    def resolve(files)
      return if files.length == 0
      @suites = {}
      @files = files
      files.uniq.each do |path|
        if result = Teaspoon::Suite.resolve_spec_for(path)
          suite = @suites[result[:suite]] ||= []
          suite << result[:path]
        end
      end
    end

    def start_server
      @server = Teaspoon::Server.new
      @server.start
    end

    def suites
      return [@options[:suite]] if @options[:suite].present?
      return @suites.keys if @suites.present?
      Teaspoon.configuration.suites.keys
    end

    def driver
      @driver ||= Teaspoon::Drivers.const_get("#{Teaspoon.configuration.driver.to_s.camelize}Driver").new
    end

    def filter(suite)
      parts = []
      parts << "grep=#{URI::encode(@options[:filter])}" if @options[:filter].present?
      (@suites[suite] || @files).flatten.each { |file| parts << "file[]=#{URI::encode(file)}" }
      "#{parts.join('&')}" if parts.present?
    end

    def url(suite)
      base_url = ["#{@server.url}#{Teaspoon.configuration.mount_at}", suite].join('/')
      [base_url, filter(suite)].compact.join('?')
    end
  end
end
