begin
  require "selenium-webdriver"
rescue LoadError
  STDOUT.print("Could not find Selenium Webdriver. Install the selenium-webdriver gem.\n")
  exit(1)
end

module Teaspoon
  module Drivers
    class SeleniumDriver < Base

      def initialize(options = nil)
        options ||= {}
        case options
        when Hash   then @options = options
        when String then @options = JSON.parse(options)
        else raise Teaspoon::UnknownDriverOptions, "Unknown driver options -- supply a hash or json string"
        end

      rescue JSON::ParserError
        raise Teaspoon::UnknownDriverOptions, "Malformed driver options -- supply a hash or json string"
      end

      def run_specs(runner, url)
        driver = Selenium::WebDriver.for(driver_options[:client_driver])
        driver.navigate.to(url)

        Selenium::WebDriver::Wait.new(driver_options).until do
          done = driver.execute_script("return window.Teaspoon && window.Teaspoon.finished")
          driver.execute_script("return window.Teaspoon && window.Teaspoon.getMessages() || []").each do |line|
            runner.process("#{line}\n")
          end
          done
        end
      ensure
        driver.quit if driver
      end

      protected

      def driver_options
        @driver_options ||= HashWithIndifferentAccess.new({
          client_driver: :firefox,
          timeout: Teaspoon.configuration.driver_timeout.to_i,
          interval: 0.01,
          message: "Timed out"
        }).merge(@options)
      end
    end
  end
end

