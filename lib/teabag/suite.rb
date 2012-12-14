module Teabag
  class Suite

    attr_accessor :config
    delegate :stylesheets, :helper, to: :config

    def initialize(name = :default)
      @config = suite_configuration(name)
    end

    def javascripts
      [config.javascripts, helper, specs].flatten
    end

    def specs
      Dir[config.matcher.present? ? Teabag.configuration.root.join(config.matcher) : ""].map do |filename|
        asset_path_from_filename(File.expand_path(filename))
      end
    end

    protected

    def suite_configuration(name)
      name ||= :default
      config = Teabag.configuration.suites[name.to_s]
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
