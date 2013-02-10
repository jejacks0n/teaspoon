module Teabag
  class Coverage
    include Teabag::Utility

    def initialize(data)
      @data = data
    end

    def reports
      Dir.mktmpdir do |path|
        input = File.join(path, 'coverage.json')
        File.write(input, @data.to_json)
        results = []
        for format in Teabag.configuration.coverage_reports
          result = generate_report(input, format)
          results << result if ["text", "text-summary"].include?(format.to_s)
        end
        results.join("\n")
      end
    end

    private

    def generate_report(input, format)
      result = %x{#{executable} report #{format} #{input.shellescape}}
      raise "Could not generate coverage report for #{format}" unless $?.exitstatus == 0
      result.gsub("Done\n", "").gsub("Using reporter [#{format}]\n", "").gsub("\n\n", "")
    end

    def executable
      @executable ||= which("istanbul")
    end
  end
end
