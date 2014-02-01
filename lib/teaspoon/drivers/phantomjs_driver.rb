require "teaspoon/runner"
require 'teaspoon/utility'

begin
  require "phantomjs"
rescue LoadError
end

module Teaspoon
  module Drivers
    class PhantomjsDriver < BaseDriver
      include Teaspoon::Utility

      def initialize(options = "")
        @options = options
      end

      def run_specs(suite, url)
        runner = Teaspoon::Runner.new(suite)

        run(*cli_arguments(url)) do |line|
          runner.process(line) if line && line.strip != ""
        end

        runner.failure_count
      end

      protected

      def run(*args, &block)
        IO.popen([executable, *args]) { |io|
          io.each(&block)
        }
      end

      def cli_arguments(url)
        [@options.to_s.split(" "), script, url].flatten.compact
      end

      def executable
        executable ||= which('phantomjs')
        executable = Phantomjs.path if executable.blank? && defined?(::Phantomjs)
        if executable.blank?
          STDOUT.print("Could not find PhantomJS. Install phantomjs or try the phantomjs gem.")
          exit(1)
        end
        executable
      end

      def script
        File.expand_path("../phantomjs/runner.js", __FILE__)
      end
    end
  end
end
