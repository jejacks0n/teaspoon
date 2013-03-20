require "phantomjs"
require "teabag/runner"
require 'teabag/utility'

module Teabag
  module Drivers
    class PhantomjsDriver < BaseDriver
      include Teabag::Utility

      def run_specs(suite, url)
        runner = Teabag::Runner.new(suite)

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
