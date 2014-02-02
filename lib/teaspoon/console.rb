require 'open-uri'
require 'teaspoon/environment'
require 'teaspoon/export'

module Teaspoon
  class Console

    def initialize(options = {})
      @options = options
      @suites = {}
      Teaspoon::Environment.load(@options)

      start_server
    end

    def failures?
      execute
    end

    def execute(options = {})
      @options.merge!(options)
      @suites = {}
      resolve(@options[:files])

      failure_count = 0
      suites.each do |suite|
        export(suite) if @options.include?(:export)
        STDOUT.print("Teaspoon running #{suite} suite at #{url(suite)}\n") unless Teaspoon.configuration.suppress_log
        failure_count += run_specs(suite)
      end
      failure_count > 0
    rescue Teaspoon::Failure
      true
    rescue Teaspoon::RunnerException
      true
    end

    def run_specs(suite)
      url = url(suite)
      url += url.include?("?") ? "&" : "?"
      url += "reporter=Console"
      driver.run_specs(suite, url)
    end

    def export(suite)
      suite_url = url(suite)
      export_path = @options[:export] if String === @options[:export]
      exporter = Export.new(:suite => suite, :url => url(suite), :output_path => export_path)
      STDOUT.print "Teaspoon exporting #{suite} suite at #{suite_url} to #{exporter.output_path}\n" unless Teaspoon.configuration.suppress_log
      exporter.execute
    end

    protected

    def resolve(files = [])
      return if files.length == 0
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
      Teaspoon.configuration.suite_configs.keys
    end

    def driver
      return @driver if @driver
      klass = "#{Teaspoon.configuration.driver.to_s.camelize}Driver"
      @driver = Teaspoon::Drivers.const_get(klass).new(Teaspoon.configuration.driver_options)
    end

    def filter(suite)
      parts = []
      parts << "grep=#{URI::encode(@options[:filter])}" if @options[:filter].present?
      (@suites[suite] || @options[:files] || []).flatten.each { |file| parts << "file[]=#{URI::encode(file)}" }
      "#{parts.join('&')}" if parts.present?
    end

    def url(suite)
      base_url = ["#{@server.url}#{Teaspoon.configuration.mount_at}", suite].join('/')
      [base_url, filter(suite)].compact.join('?')
    end
  end
end
