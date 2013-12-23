module Teaspoon
  class Coverage
    include Teaspoon::Utility

    def initialize(data)
      @data = data
    end

    def reports
      Dir.mktmpdir do |path|
        input = File.join(path, 'coverage.json')
        File.open(input, 'w') { |file| file.write(@data.to_json) }
        results = []
        for format in Teaspoon.configuration.coverage_reports
          result = generate_report(input, format)
          results << result if ["text", "text-summary"].include?(format.to_s)
        end
        Teaspoon::CheckCoverage.new(input).check_coverage
        "\n#{results.join("\n\n")}\n"
      end
    end

    private

    def generate_report(input, format)
      result = %x{#{executable} report #{format} #{input.shellescape} --dir #{Teaspoon.configuration.coverage_output_dir}}
      raise "Could not generate coverage report for #{format}" unless $?.exitstatus == 0
      result.gsub("Done", "").gsub("Using reporter [#{format}]", "").strip
    end

    def executable
      @executable ||= istanbul()
    end
  end
end
