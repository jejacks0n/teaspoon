module Teaspoon
  module Drivers
    class CapybaraWebkitDriver < Base
      register_driver :capybara_webkit

      def initialize(_options = nil)
        load_driver
      end

      def run_specs(runner, url)
        session.visit(url)

        session.document.synchronize(Teaspoon.configuration.driver_timeout.to_i) do
          done = session.evaluate_script("window.Teaspoon && window.Teaspoon.finished")
          (session.evaluate_script("window.Teaspoon && window.Teaspoon.getMessages()") || []).each do |line|
            runner.process("#{line}\n")
          end
          done
        end
      end

      private

      def session
        @session ||= Capybara::Session.new(:webkit)
      end

      # :nocov:
      def load_driver
        begin
          require "capybara-webkit"
        rescue LoadError
          Teaspoon.abort("Could not find Capybara Webkit. Install the capybara-webkit gem.")
        end
      end
      # :nocov:
    end
  end
end
