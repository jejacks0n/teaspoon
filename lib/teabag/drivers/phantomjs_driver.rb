require "phantomjs"
require "teabag/runner"

module Teabag
  module Drivers
    class PhantomjsDriver < BaseDriver

      # inject into phantomjs to override the bin path
      Phantomjs.send :extend, Module.new do
        def get_executable
          Teabag.configuration.phantomjs_bin
        end
      end if Teabag.configuration.phantomjs_bin.present?

      def run_specs(suite, url)
        runner = Teabag::Runner.new(suite)

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
