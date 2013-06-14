require "phantomjs"
require "teaspoon/runner"
require 'teaspoon/utility'

module Teaspoon
  module Drivers
    class PhantomjsDriver < BaseDriver
      include Teaspoon::Utility

      def run_specs(suite, url)
        runner = Teaspoon::Runner.new(suite)

        Phantomjs.instance_variable_set(:@path, executable)
        Phantomjs.run(script, url) do |line|
          runner.process(line)
        end

        runner.failure_count
      end

      protected

      def executable
        @executable ||= which('phantomjs')
      end

      def script
        File.expand_path("../phantomjs/runner.coffee", __FILE__)
      end
    end
  end
end
