# :nocov:
begin
  require "ferrum"
rescue LoadError
  Teaspoon.abort("Could not find Ferrum. Install the ferrum gem.")
end
# :nocov:

require "teaspoon/driver/base"

module Teaspoon
  module Driver
    class Ferrum < Base
      def initialize(options = nil)
        options ||= {}
        case options
        when Hash then @options = options
        when String then @options = JSON.parse(options)
        else raise Teaspoon::DriverOptionsError.new(types: "hash or json string")
        end
      rescue JSON::ParserError
        raise Teaspoon::DriverOptionsError.new(types: "hash or json string")
      end

      def run_specs(runner, url)
        driver = ::Ferrum::Browser.new
        driver.go_to(url)

        if driver.evaluate("window.Teaspoon")
          until driver.evaluate("window.Teaspoon.finished")
            sleep 0.01
          end
          driver.evaluate("window.Teaspoon.getMessages() || []").each do |line|
            runner.process("#{line}\n")
          end
        end
      ensure
        driver.quit if driver
      end

      protected

        def driver_options
          @driver_options ||= HashWithIndifferentAccess.new(
            timeout: Teaspoon.configuration.driver_timeout.to_i            
          ).merge(@options)
        end
    end
  end
end
