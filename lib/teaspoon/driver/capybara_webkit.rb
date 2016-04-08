# :nocov:
begin
  require "capybara-webkit"
rescue LoadError
  Teaspoon.abort("Could not find Capybara Webkit. Install the capybara-webkit gem.")
end
# :nocov:

require "teaspoon/driver/base"

module Teaspoon
  module Driver
    class CapybaraWebkit < Base
      class TeaspoonNotFinishedError < StandardError; end

      def initialize(_options = nil)
        # TODO: potential memory leak
        Capybara.register_driver :teaspoon_webkit do |app|
          Capybara::Webkit::Driver.new(app, stderr: self, debug: true)
        end
      end

      def run_specs(runner, url)
        @runner = runner

        session.visit(url)
        session.document.synchronize(Teaspoon.configuration.driver_timeout.to_i, errors: [TeaspoonNotFinishedError]) do
          done = session.evaluate_script("window.Teaspoon && window.Teaspoon.finished")
          raise TeaspoonNotFinishedError unless done
        end
      end

      def write(string)
        string.match(/\|([^|]*)$/) { |m| @runner.process(m[1]) if m[1] }
        0 # return 0 because I don't know what I'm doing and needed to simulate a STDOUT.write return value.
      end

      private

      def session
        @session ||= Capybara::Session.new(:teaspoon_webkit)
      end
    end
  end
end
