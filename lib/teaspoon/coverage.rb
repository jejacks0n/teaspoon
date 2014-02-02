# todo: redo
module Teaspoon
  class Coverage
    include Teaspoon::Utility

    def initialize(data, suite_name)
      @data = data
      @suite_name = suite_name
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
        Teaspoon::Coverage::Thresholds.new(executable, input).assert_coverage
        "\n#{results.join("\n\n")}\n"
      end
    end

    private

    def generate_report(input, format)
      output_path = File.join(Teaspoon.configuration.coverage_output_dir, @suite_name)
      result = %x{#{executable} report #{format} #{input.shellescape} --dir #{output_path}}
      raise "Could not generate coverage report for #{format}" unless $?.exitstatus == 0
      result.gsub("Done", "").gsub("Using reporter [#{format}]", "").strip
    end

    def executable
      @executable ||= which("istanbul")
    end

    class Thresholds
      def initialize(executable, input)
        @executable = executable
        @input = input
      end

      def assert_coverage
        do_check_coverage(check_coverage_options.strip) unless check_coverage_options.nil?
      end

      private

      def do_check_coverage(options)
        result = %x{#{executable} check-coverage #{options} #{@input.shellescape}}
        raise "Coverage threshold failure (current levels: #{options})" unless $?.exitstatus == 0
        result.strip
      end

      def check_coverage_options
        @check_coverage_options ||= %w{statements functions branches lines}.inject("") do |line, coverage_type|
          threshold = Teaspoon.configuration.send(:"#{coverage_type}_coverage_threshold")

          line += "--#{coverage_type} #{threshold} " unless threshold.nil?
        end
      end
    end
  end
end
