require "sprockets/environment"

module Teaspoon
  class Instrumentation
    extend Teaspoon::Utility

    def self.add_to(response, env)
      return response unless add?(response, env)
      Teaspoon::Instrumentation.new(response).instrumented_response
    end

    def self.add?(response, env)
      executable &&                                                   # we have an executable
      env["QUERY_STRING"].to_s =~ /instrument=(1|true)/ &&            # the instrument param was provided
      response[0] == 200 &&                                           # the status is 200 (304 might be needed here too)
      response[1]["Content-Type"].to_s == "application/javascript" && # the format is something that we care about
      response[2].respond_to?(:source)                                # it looks like an asset
    end

    def self.executable
      return @executable if @executable_checked
      @executable_checked = true
      @executable = which("istanbul")
    end

    def initialize(response)
      @response = response
    end

    def instrumented_response
      status, headers, asset = @response
      headers, asset = [headers.clone, asset.clone]

      result = add_instrumentation(asset)

      asset.instance_variable_set(:@source, result)
      asset.instance_variable_set(:@length, headers["Content-Length"] = result.bytesize.to_s)

      [status, headers, asset]
    end

    protected

    def add_instrumentation(asset)
      source_path = asset.pathname.to_s
      Dir.mktmpdir do |temp_path|
        input_path = File.join(temp_path, File.basename(source_path)).sub(/\.js.+/, ".js")
        File.open(input_path, 'w') { |f| f.write(asset.source) }
        instrument(input_path).gsub(input_path, source_path)
      end
    end

    def instrument(input)
      result = %x{#{self.class.executable} instrument --embed-source #{input.shellescape}}
      return result if $?.exitstatus == 0
      raise Teaspoon::DependencyFailure, "Could not generate instrumentation for #{File.basename(input)}"
    end
  end

  module SprocketsInstrumentation
    def call(env)
      Teaspoon::Instrumentation.add_to(super, env)
    end
  end
end
