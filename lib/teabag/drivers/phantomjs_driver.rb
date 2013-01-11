require "phantomjs"
require "teabag/runner"

module Teabag
  module Drivers
    class PhantomjsDriver < BaseDriver

      def run_specs(suite, url)
        runner = Teabag::Runner.new(suite)

        Phantomjs.instance_variable_set(:@executable, Teabag.configuration.phantomjs_bin)
        Phantomjs.run(script, url) do |line|
          runner.process(line)
        end

        runner.failure_count
      end

      protected

      def script
        File.expand_path("../phantomjs/runner.coffee", __FILE__)
      end
    end
  end
end
