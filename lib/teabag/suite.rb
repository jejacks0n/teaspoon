module Teabag
  class Suite

    attr_accessor :config, :name
    delegate :stylesheets, :helper, to: :config

    def self.all
      Teabag.configuration.suites.keys.map { |suite| Teabag::Suite.new(suite: suite) }
    end

    def self.resolve(file)
      file = File.expand_path(file)
      all.each do |suite|
        return suite.name if suite.include?(file)
      end
      nil
    end

    def self.resolve_spec_for(file)
      suites = all
      suites.each do |suite|
        spec = suite.include_spec_for?(file)
        return {suite: suite.name, path: spec} if spec
      end
      false
    end

    def initialize(options = {})
      @options = options
      @name = (@options[:suite] || :default).to_s
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

    def suites
      {all: Teabag.configuration.suites.keys, active: name}
    end

    def spec_files
      glob.map { |file| {path: file, name: asset_from_file(file)} }
    end

    def link(params = {})
      query = "?#{params.to_query}" if params.present?
      [Teabag.configuration.mount_at, name, query].compact.join("/")
    end

    def include?(file)
      glob.include?(file)
    end

    def include_spec_for?(file)
      return file if include?(file)
      glob.each do |spec|
        return spec if spec.include?(file)
      end
      false
    end

    protected

    def specs
      files = specs_from_file
      return files unless files.empty?
      glob.map { |file| asset_from_file(file) }
    end

    def glob
      @glob ||= Dir[config.matcher.present? ? Teabag.configuration.root.join(config.matcher) : ""]
    end

    def suite_configuration
      config = Teabag.configuration.suites[name]
      raise Teabag::UnknownSuite unless config.present?
      Teabag::Configuration::Suite.new(&config)
    end

    def specs_from_file
      Array(@options[:file]).map do |filename|
        asset_from_file(File.expand_path(Teabag.configuration.root.join(filename)))
      end
    end

    def asset_from_file(original)
      filename = original
      Rails.application.config.assets.paths.each do |path|
        filename = filename.gsub(%r(^#{path}[\/|\\]), "")
      end
      raise Teabag::AssetNotServable, "#{filename} is not within an asset path" if filename == original
      filename.gsub(/(\.js\.coffee|\.coffee)$/, ".js")
    end
  end
end
