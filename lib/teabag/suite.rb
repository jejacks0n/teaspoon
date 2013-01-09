module Teabag
  class Suite

    attr_accessor :config
    delegate :stylesheets, :helper, to: :config

    def initialize(options = {})
      @options = options
      @name = @options[:suite] || :default
      @config = suite_configuration
    end

    def javascripts
      [core_javascripts, spec_javascripts].flatten
    end

    def core_javascripts
      config.javascripts
    end

    def spec_javascripts
      [helper, specs].flatten
    end

    def specs
      files = specs_from_file
      return files unless files.empty?

      Dir[config.matcher.present? ? Teabag.configuration.root.join(config.matcher) : ""].map do |filename|
        asset_path_from_filename(File.expand_path(filename))
      end
    end

    def suites
      {all: Teabag.configuration.suites.keys, active: @name.to_s}
    end

    protected

    def specs_from_file
      Array(@options[:file]).map do |filename|
        asset_path_from_filename(File.expand_path(Teabag.configuration.root.join(filename)))
      end
    end

    def suite_configuration
      config = Teabag.configuration.suites[@name.to_s]
      raise Teabag::UnknownSuite unless config.present?
      Teabag::Configuration::Suite.new(&config)
    end

    def asset_path_from_filename(original)
      filename = original
      Rails.application.config.assets.paths.each do |path|
        filename = filename.gsub(%r(^#{path}[\/|\\]), "")
      end
      raise Teabag::AssetNotServable, "#{filename} is not within an asset path" if filename == original
      filename.gsub(/(\.js\.coffee|\.coffee)$/, ".js")
    end
  end
end
