require "tilt"
require "sprockets/environment"

module Teabag
  class Instrumentation < Tilt::Template
    extend Teabag::Utility

    def self.env=(env)
      @env = env
    end

    def self.env
      @env || {}
    end

    def self.add?
      executable.present? && !!(env["QUERY_STRING"].to_s =~ /instrument=(1|t)/)
    end

    def self.executable
      @executable ||= which("istanbul")
    end

    def prepare; end

    def evaluate(context, locals)
      return data unless Teabag::Instrumentation.add?

      Dir.mktmpdir do |path|
        filename = File.basename(file)
        input = File.join(path, filename).sub(/\.js.+/, ".js")
        File.write(input, data)

        instrument(input).gsub(input, file.to_s)
      end
    end

    private

    def instrument(input)
      result = %x{#{Teabag::Instrumentation.executable} instrument --embed-source #{input.shellescape}}
      raise "Could not generate instrumentation for #{File.basename(input)}" unless $?.exitstatus == 0
      result
    end
  end

  # Reopen sprockets environment and add functionality.
  # Annoyingly, using send(:include) didn't allow the find_asset override.
  class ::Sprockets::Environment
    def call(env)
      Teabag::Instrumentation.env = env
      super
    ensure
      Teabag::Instrumentation.env = env
    end
  end
end
