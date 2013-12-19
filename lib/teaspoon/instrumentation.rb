require "sprockets/environment"

module Teaspoon
  class Instrumentation
    extend Teaspoon::Utility

    def self.executable
      @executable ||= istanbul()
    end

    def self.add?(response, env)
      (
        executable.present? &&                                          # we have an executable
        env["QUERY_STRING"].to_s =~ /instrument=(1|true)/ &&            # the instrument param was provided
        response[0] == 200 &&                                           # the status is 200
        response[1]["Content-Type"].to_s == "application/javascript" && # the format is something that we care about
        response[2].respond_to?(:source)                                # it looks like an asset
      )
    end

    def self.add_to(response, env)
      return response unless add?(response, env)
      Teaspoon::Instrumentation.new(response)
      response
    end

    def initialize(response)
      status, headers, @asset = response
      headers, @asset = [headers.clone, @asset.clone]
      result = process_and_instrument
      length = result.bytesize.to_s

      headers["Content-Length"] = length
      @asset.instance_variable_set(:@source, result)
      @asset.instance_variable_set(:@length, length)

      response.replace([status, headers, @asset])
    end

    private

    def process_and_instrument
      file = @asset.pathname.to_s
      Dir.mktmpdir do |path|
        filename = File.basename(file)
        input = File.join(path, filename).sub(/\.js.+/, ".js")
        File.open(input, 'w') { |file| file.write(@asset.source) }

        instrument(input).gsub(input, file)
      end
    end

    def instrument(input)
      result = %x{#{Teaspoon::Instrumentation.executable} instrument --embed-source #{input.shellescape}}
      raise "Could not generate instrumentation for #{File.basename(input)}" unless $?.exitstatus == 0
      result
    end
  end

  module SprocketsInstrumentation
    def call(env)
      Teaspoon::Instrumentation.add_to(super, env)
    end
  end
end
