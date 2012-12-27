require "phantomjs"
require "teabag/runner"

module Phantomjs
  private

  def get_executable_with_override
    return Teabag.configuration.phantomjs_bin if Teabag.configuration.phantomjs_bin.present?
    get_executable_without_override
  end
  alias_method_chain :get_executable, :override
end

module Teabag
  module Drivers
    class PhantomjsDriver < BaseDriver

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
