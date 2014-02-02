begin
  require "selenium-webdriver"
rescue LoadError
  STDOUT.print("Could not find Selenium Webdriver. Install selenium-webdriver gem.")
  exit(1)
end


module Teaspoon
  module Drivers
    class SeleniumDriver < Base

      def initialize(options = nil)
      end

      def run_specs(suite, url)
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

        return runner.failure_count
      ensure
        driver.quit if driver
      end
    end
  end
end

