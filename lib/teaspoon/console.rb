require "teaspoon/environment"

module Teaspoon
  class Console
    def initialize(options = {})
      @default_options = options
      @suites = {}
      Teaspoon::Environment.check_env!(options[:environment])
      Teaspoon::Environment.load(options)

      @server = start_server
    rescue Teaspoon::ServerError => e
      Teaspoon.abort(e.message)
    end

    def options
      @execute_options ||= {}
      @default_options ||= {}
      @default_options.merge(@execute_options)
    end

    def failures?
      !execute
    end

    def execute(options = {})
      execute_without_handling(options)
    rescue Teaspoon::Failure
      false
    rescue Teaspoon::RunnerError => e
      log(e.message)
      false
    rescue Teaspoon::Error => e
      Teaspoon.abort(e.message)
    end

    def execute_without_handling(execute_options = {})
      @execute_options = execute_options
      @suites = {}
      resolve(options[:files])

      0 == suites.inject(0) do |failures, suite|
        export(suite) if options.include?(:export)
        failures += run_specs(suite)
        log("") # empty line for space
        failures
      end
    end

    def run_specs(suite)
      raise Teaspoon::UnknownSuite.new(name: suite) unless Teaspoon.configuration.suite_configs[suite.to_s]

      log("Teaspoon running #{suite} suite at #{base_url_for(suite)}")
      runner = Teaspoon::Runner.new(suite)
      driver.run_specs(runner, url_for(suite))
      raise Teaspoon::Failure if Teaspoon.configuration.fail_fast && runner.failure_count > 0
      runner.failure_count
    end

    def export(suite)
      raise Teaspoon::UnknownSuite.new(name: suite) unless Teaspoon.configuration.suite_configs[suite.to_s]

      log("Teaspoon exporting #{suite} suite at #{base_url_for(suite)}")
      Teaspoon::Exporter.new(suite, url_for(suite, false), options[:export]).export
    end

    protected

    def resolve(files = [])
      return if files.blank?
      files.uniq.each do |path|
        if result = Teaspoon::Suite.resolve_spec_for(path)
          suite = @suites[result[:suite]] ||= []
          suite << result[:path]
        end
      end
    end

    def start_server
      server = Teaspoon::Server.new
      log("Starting the Teaspoon server...") unless server.responsive?
      server.start
      server
    end

    def suites
      return [options[:suite]] if options[:suite].present?
      return @suites.keys if @suites.present?
      Teaspoon.configuration.suite_configs.keys
    end

    def driver
      return @driver if @driver
      driver = Teaspoon::Driver.fetch(Teaspoon.configuration.driver)
      @driver = driver.new(Teaspoon.configuration.driver_options)
    end

    def base_url_for(suite)
      ["#{@server.url}#{Teaspoon.configuration.mount_at}", suite].join("/")
    end

    def url_for(suite, console = true)
      url = [base_url_for(suite), filter(suite)].compact.join("?")
      url += "#{(url.include?('?') ? '&' : '?')}reporter=Console" if console
      url
    end

    def filter(suite)
      parts = []
      parts << "grep=#{URI::encode(options[:filter])}" if options[:filter].present?
      (@suites[suite] || options[:files] || []).flatten.each { |file| parts << "file[]=#{URI::encode(file)}" }
      "#{parts.join('&')}" if parts.present?
    end

    def log(str)
      STDOUT.print("#{str}\n") unless Teaspoon.configuration.suppress_log
    end
  end
end
