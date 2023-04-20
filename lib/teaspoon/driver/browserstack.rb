# :nocov:
begin
  require "selenium-webdriver"
rescue LoadError
  Teaspoon.abort("Could not find Selenium Webdriver. Install the selenium-webdriver gem.")
end
# :nocov:

require "teaspoon/driver/base"

# Need to have BrowserStackLocal binary (https://www.browserstack.com/local-testing#command-line)
# running in the background to use this driver.
module Teaspoon
  module Driver
    class BrowserStack < Base
      MAX_PARALLEL = 10

      def initialize(options = nil)
        options ||= {}
        case options
        when Hash then @options = options.symbolize_keys
        when String then @options = JSON.parse(options).symbolize_keys
        else raise Teaspoon::DriverOptionsError.new(types: "hash or json string")
        end

        unless @options[:capabilities] && @options[:capabilities].is_a?(Array)
          raise Teaspoon::DriverOptionsError.new(types: "capabilities array." \
                                                 "Options must have a key 'capabilities' of type array")
        end
        @options[:capabilities].each(&:symbolize_keys!)
      rescue JSON::ParserError
        raise Teaspoon::DriverOptionsError.new(types: "hash or json string")
      end

      def run_specs(runner, url)
        parallelize do
          driver = Thread.current[:driver]
          driver.navigate.to(url)
          ::Selenium::WebDriver::Wait.new(driver_options).until do
            done = driver.execute_script("return window.Teaspoon && window.Teaspoon.finished")
            driver.execute_script("return window.Teaspoon && window.Teaspoon.getMessages() || []").each do |line|
              runner.process("#{line}\n")
            end
            done
          end
        end
      end

      protected

        def parallelize
          threads = []
          left_capabilities = capabilities
          until left_capabilities.empty?
            left_capabilities.pop(max_parallel).each do |desired_capability|
              desired_capability[:"browserstack.local"] = true
              desired_capability[:project] = driver_options[:project] if driver_options[:project]
              desired_capability[:build] = driver_options[:build] if driver_options[:build]
              threads << Thread.new do
                driver = ::Selenium::WebDriver.for(:remote, url: hub_url, desired_capabilities: desired_capability)
                Thread.current[:driver] = driver
                capability = driver.capabilities

                Thread.current[:name] = "Session on #{capability[:platform].to_s.strip}," \
                  "#{capability[:browser_name].to_s.strip} #{capability[:version].to_s.strip}"

                yield
                Thread.current[:driver].quit
                STDOUT.print("#{Thread.current[:name]} Completed\n") unless Teaspoon.configuration.suppress_log
              end
            end
            threads.each(&:join)
            threads = []
          end
        end

        def capabilities
          driver_options[:capabilities]
        end

        def hub_url
          "https://#{username}:#{access_key}@hub.browserstack.com/wd/hub"
        end

        def username
          driver_options[:username] || ENV["BROWSERSTACK_USERNAME"]
        end

        def access_key
          driver_options[:access_key] || ENV["BROWSERSTACK_ACCESS_KEY"]
        end

        def max_parallel
          parallel = MAX_PARALLEL
          begin
            parallel = driver_options[:max_parallel].to_i if driver_options[:max_parallel].to_i > 0
          rescue
          end
          parallel
        end

        def driver_options
          @driver_options ||= HashWithIndifferentAccess.new(
            timeout: Teaspoon.configuration.driver_timeout.to_i,
            interval: 0.01,
            message: "Timed out"
          ).merge(@options)
        end
    end
  end
end
