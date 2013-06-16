require "selenium-webdriver"
require "teaspoon/runner"

module Teaspoon
  module Drivers
    class SeleniumDriver < BaseDriver

      # note: driver_cli_options which is meant to be used for CLI options to pass into the driver is 
      #       currently ignored. We use the Selenium Ruby binding, so the Selenium command-line options
      #       aren't used. There are a variety of Selenium options and browser-specific options
      #       supported by the binding that will take more thought and design to configure cleanly.
      def run_specs(suite, url, driver_cli_options = nil)
        runner = Teaspoon::Runner.new(suite)

        driver = Selenium::WebDriver.for(:firefox)
        driver.navigate.to(url)

        Selenium::WebDriver::Wait.new(timeout: 180, interval: 0.01, message: "Timed out").until do
          done = driver.execute_script("return window.Teaspoon && window.Teaspoon.finished")
          driver.execute_script("return window.Teaspoon && window.Teaspoon.getMessages() || []").each do |line|
            runner.process("#{line}\n")
          end
          done
        end

        runner.failure_count
      ensure
        driver.quit if driver
      end
    end
  end
end

