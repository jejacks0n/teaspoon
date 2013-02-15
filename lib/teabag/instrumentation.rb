require "sprockets/environment"

module Teabag
  class Instrumentation
    extend Teabag::Utility

    def self.executable
      @executable ||= which("istanbul")
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

      status, headers, asset = response
      instrumented = process(asset.pathname.to_s, asset.source)

      asset, headers = [asset.clone, headers.clone]
      headers["Content-Length"] = instrumented.length.to_s
      asset.instance_variable_set(:@source, instrumented)

      response.replace([status, headers, asset])
    end

    private

    def self.process(file, data)
      Dir.mktmpdir do |path|
        filename = File.basename(file)
        input = File.join(path, filename).sub(/\.js.+/, ".js")
        File.write(input, data)

        instrument(input).gsub(input, file)
      end
    end

    def self.instrument(input)
      result = %x{#{Teabag::Instrumentation.executable} instrument --embed-source #{input.shellescape}}
      raise "Could not generate instrumentation for #{File.basename(input)}" unless $?.exitstatus == 0
      result
    end
  end

  class ::Sprockets::Environment
    def call(env)
      Teabag::Instrumentation.add_to(super, env)
    end
  end
end
