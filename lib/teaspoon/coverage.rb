module Teaspoon
  class Coverage
    def self.configuration(name = Teaspoon.configuration.use_coverage)
      name = normalize_config_name(name)
      config = Teaspoon.configuration.coverage_configs[name]

      raise Teaspoon::UnknownCoverage.new(name: name) unless config.present?
      config[:instance] ||= Teaspoon::Configuration::Coverage.new(&config[:block])
    end

    def initialize(suite_name, data)
      @suite_name = suite_name
      @data = data
      @executable = Teaspoon::Instrumentation.executable
      @config = self.class.configuration
    end

    def generate_reports(&block)
      input_path do |input|
        results = []
        @config.reports.each do |format|
          result = generate_report(input, format)
          results << result if ["text", "text-summary"].include?(format.to_s)
        end
        block.call(results.join("\n\n")) unless results.blank?
      end
    end

    def check_thresholds(&block)
      args = threshold_args
      return if args.blank?
      input_path do |input|
        result = %x{#{@executable} check-coverage #{args.join(" ")} #{input.shellescape} 2>&1}
        return if $?.exitstatus == 0
        result = result.scan(/ERROR: .*$/).join("\n").gsub("ERROR: ", "")
        block.call(result) unless result.blank?
      end
    end

    private

    def self.normalize_config_name(name)
      return "default" if name == true
      name.to_s
    end

    def input_path(&block)
      Dir.mktmpdir do |temp_path|
        input_path = File.join(temp_path, "coverage.json")
        File.open(input_path, "w") { |f| f.write(@data.to_json) }
        block.call(input_path)
      end
    end

    def generate_report(input, format)
      output_path = File.join(@config.output_path, @suite_name)
      result = %x{#{@executable} report --include=#{input.shellescape} --dir #{output_path} #{format} 2>&1}
      return result.gsub("Done", "").gsub("Using reporter [#{format}]", "").strip if $?.exitstatus == 0
      raise Teaspoon::DependencyError.new("Unable to generate #{format} coverage report.")
    end

    def threshold_args
      %w{statements functions branches lines}.map do |assert|
        threshold = @config.send(:"#{assert}")
        "--#{assert}=#{threshold}" if threshold
      end.compact
    end
  end
end
