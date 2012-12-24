require "teabag/server"
require "teabag/runner"
require "phantomjs"
require "selenium-webdriver"

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
        failure_count += run_specs_with_selenium(suite)
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

    def run_specs_with_selenium(suite)
      runner = Teabag::Runner.new(suite)
      driver = Selenium::WebDriver.for(:firefox)
      driver.navigate.to("#{url(suite)}?reporter=Console")
      Selenium::WebDriver::Wait.new(timeout: 3000, interval: 0.01, message: "Timed out").until do
        done = driver.execute_script("return window.Teabag && window.Teabag.finished")
        driver.execute_script("return Teabag.getMessages()").each do |line|
          runner.process("#{line}\n")
        end
        done
      end
      runner.failure_count
    ensure
      driver.quit
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
