begin
  require "capybara-webkit"
rescue LoadError
  STDOUT.print("Could not find Capybara Webkit. Install the capybara-webkit gem.\n")
  exit(1)
end

module Teaspoon
  module Drivers
    class CapybaraWebkitDriver < Base
      include Capybara::DSL

      def run_specs(runner, url)
        Capybara.current_driver = :webkit
        page.visit(url)

        page.document.synchronize(Teaspoon.configuration.driver_timeout.to_i) do
          done = evaluate_script("window.Teaspoon && window.Teaspoon.finished")
          (evaluate_script("window.Teaspoon && window.Teaspoon.getMessages()") || []).each do |line|
            runner.process("#{line}\n")
          end
          done
        end
      end
    end
  end
end

