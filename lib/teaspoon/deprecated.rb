module Teaspoon

  def self.setup(&block)
    Teaspoon.dep("Teaspoon.setup is deprecated, use Teaspoon.configure instead. The /initializer/teaspoon.rb file should be removed, and a new teaspoon_env.rb file should be created by running the install generator.")
    configure(&block)
  end

  @dep_notified = {}
  def self.dep(message, category = nil)
    return if Teaspoon.configured
    if category
      return if @dep_notified[category]
      @dep_notified[category] = true if category
    end
    puts "WARNING: Deprecated - #{message}"
  end

  class Configuration

    def self.context=(*args)
      Teaspoon.dep("the teaspoon context directive is no longer used, remove it from your configuration.")
    end

    def self.fixture_path=(*args)
      Teaspoon.dep("the teaspoon fixture_path directive has been changed to fixture_paths, which expects an array, please update your configuration.")
      self.fixture_paths = args
    end

    def self.driver_cli_options=(val)
      Teaspoon.dep("the teaspoon driver_cli_options directive is no longer used, use driver_options instead.")
      self.driver_options = val
    end

    @coverage_dep_message = <<-MESSAGE
teaspoon coverage directive has changed and is now more flexible, define coverage using a block instead:
  config.coverage :CI do |coverage|
    coverage.reports = ["html", "text-summary"]
    coverage.output_path = "coverage"
    coverage.statements = 50 # statement threshold required
    coverage.functions = 50 # function threshold required
    coverage.branches = 50 # branch threshold required
    coverage.lines = nil # no line threshold
  end
  > run: teaspoon --coverage=CI --suite=default
  > set: config.use_coverage = "CI"
    MESSAGE

    for method in %w{coverage coverage_reports coverage_output_dir statements_coverage_threshold functions_coverage_threshold branches_coverage_threshold lines_coverage_threshold}
      define_singleton_method("#{method}=") do |val|
        Teaspoon.dep(@coverage_dep_message, :coverage)
      end
    end

    class Suite

      def js_config=(*args)
        Teaspoon.dep("the teaspoon suite js_config directive is no longer used, use the install generator to install the boot partial and customize it instead.", :js_config)
      end

      def normalize_asset_path=(*args)
        Teaspoon.dep("the teaspoon suite normalize_asset_path directive is no longer used, reopen Teaspoon::Suite and define a normalize_js_extension method instead.", :normalize_asset_path)
      end
    end
  end
end
