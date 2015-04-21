module Teaspoon
  module Drivers
    class PhantomjsDriver < Base
      register_driver :phantomjs

      include Teaspoon::Utility

      def initialize(options = nil)
        load_driver

        options ||= []
        case options
        when Array then @options = options
        when String then @options = options.split(" ")
        when Hash then @options = options.map { |k, v| "--#{k}=#{v}" }
        else raise Teaspoon::DriverOptionsError.new(types: "string, array or hash")
        end
      end

      def run_specs(runner, url)
        run(*driver_options(url)) do |line|
          runner.process(line) if line && line.strip != ""
        end
      end

      protected

      def run(*args, &block)
        IO.popen([executable, *args].join(" ")) { |io| io.each(&block) }
      end

      def driver_options(url)
        [
          @options,
          escape_quotes(script),
          escape_quotes(url),
          Teaspoon.configuration.driver_timeout
        ].flatten.compact
      end

      def escape_quotes(string)
        %{"#{string.gsub('"', '\"')}"}
      end

      def executable
        return @executable if @executable
        @executable = which("phantomjs")
        @executable = Phantomjs.path if @executable.blank? && defined?(::Phantomjs)
        return @executable unless @executable.blank?
        raise Teaspoon::MissingDependencyError.new("Unable to locate phantomjs. Install it or use the phantomjs gem.")
      end

      def script
        File.expand_path("../phantomjs/runner.js", __FILE__)
      end

      # :nocov:
      def load_driver
        begin
          require "phantomjs"
        rescue LoadError
          # if we can't load phantomjs, assume the cli is installed and in the path
        end
      end
      # :nocov:
    end
  end
end
