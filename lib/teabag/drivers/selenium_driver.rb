require "selenium-webdriver"
require "teabag/runner"

module Teabag
  module Drivers
    class SeleniumDriver < BaseDriver

      def run_specs(suite, url)
        runner = Teabag::Runner.new(suite)

        driver = Selenium::WebDriver.for(:firefox)
        driver.navigate.to(url)

        Selenium::WebDriver::Wait.new(timeout: 180, interval: 0.01, message: "Timed out").until do
          done = driver.execute_script("return window.Teabag && window.Teabag.finished")
          driver.execute_script("return window.Teabag && window.Teabag.getMessages() || []").each do |line|
            runner.process("#{line}\n")
          end
          done
        end

        runner.failure_count
      ensure
        driver.quit
      end
    end
  end
end

