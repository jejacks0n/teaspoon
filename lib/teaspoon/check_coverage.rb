module Teaspoon
  class CheckCoverage
    include Teaspoon::Utility

    def initialize(input)
      @input = input
    end

    def check_coverage
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

    def executable
      @executable ||= which("istanbul")
    end
  end
end
