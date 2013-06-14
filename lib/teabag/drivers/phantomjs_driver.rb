require "phantomjs"
require "teabag/runner"
require 'teabag/utility'

module Teabag
  module Drivers
    class PhantomjsDriver < BaseDriver
      include Teabag::Utility

      def run_specs(suite, url, driver_cli_options)
        runner = Teabag::Runner.new(suite)

        Phantomjs.instance_variable_set(:@path, executable)
        # Phantomjs.run takes the command-line args as an array, so if we need to pass in switches/flags, need to split on space
        Phantomjs.run(*([driver_cli_options && driver_cli_options.split(" "), script, url].flatten.compact)) do |line|
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
