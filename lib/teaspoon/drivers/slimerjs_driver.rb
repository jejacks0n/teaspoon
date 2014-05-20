begin
  require "slimerjs"
rescue LoadError
  # if we can't load slimerjs, assume the cli is installed and in the path
end

module Teaspoon
  module Drivers
    class SlimerjsDriver < Base
      include Teaspoon::Utility

      def initialize(options = nil)
        options ||= []
        case options
        when Array  then @options = options
        when String then @options = options.split(" ")
        when Hash   then @options = options.map { |k, v| "--#{k}=#{v}" }
        else raise Teaspoon::UnknownDriverOptions, "Unknown driver options -- supply a string, array or hash"
        end
      end

      def run_specs(runner, url)
        run(*driver_options(url)) do |line|
          runner.process(line) if line && line.strip != ""
        end
      end

      protected

      def run(*args, &block)
        IO.popen([executable, *args].join(' ')) { |io| io.each(&block) }
      end

      def driver_options(url)
        [@options, script, url.shellescape, Teaspoon.configuration.driver_timeout].flatten.compact
      end

      def executable
        return @executable if @executable
        @executable = which("slimerjs")
        @executable = Slimerjs.path if @executable.blank? && defined?(::Slimerjs)
        return @executable unless @executable.blank?
        raise Teaspoon::MissingDependency, "Could not find SlimerJS. Install slimerjs or try the slimerjs gem."
      end

      def script
        File.expand_path("../slimerjs/runner.js", __FILE__)
      end
    end
  end
end
