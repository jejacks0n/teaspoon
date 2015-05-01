module Teaspoon
  class Suite
    def self.all
      @all ||= Teaspoon.configuration.suite_configs.keys.map { |suite| Teaspoon::Suite.new(suite: suite) }
    end

    def self.resolve_spec_for(file)
      all.each do |suite|
        spec = suite.include_spec_for?(file)
        return { suite: suite.name, path: spec } if spec
      end
      false
    end

    attr_accessor :config, :name
    delegate :helper, :stylesheets, :javascripts, :boot_partial, :body_partial, :hooks,
             to: :config

    def initialize(options = {})
      @options = options
      @name = (@options[:suite] || :default).to_s
      @config = suite_configuration
      @env = Rails.application.assets
    end

    def spec_files
      glob.map { |file| { path: file, name: asset_from_file(file) } }
    end

    def spec_assets(include_helper = true)
      assets = specs
      assets.unshift(helper) if include_helper && helper
      asset_tree(assets)
    end

    def include_spec_for?(file)
      return file if glob.include?(file)
      paths = glob.select { |path| path.include?(file) }
      return paths unless paths.empty?
      false
    end

    protected

    def specs
      files = specs_from_file
      return files unless files.empty?
      glob.map { |file| asset_from_file(file) }
    end

    def asset_tree(sources)
      sources.map do |source|
        asset = @env.find_asset(source)
        if asset && asset.respond_to?(:logical_path) && config.expand_assets
          asset.to_a.map { |a| asset_url(a) }
        else
          source unless source.blank?
        end
      end.flatten.compact.uniq
    end

    def asset_url(asset)
      params = "?body=1"
      params << "&instrument=1" if instrument_file?(asset.pathname.to_s)
      "#{asset.logical_path}#{params}"
    end

    def instrument_file?(file)
      return false unless @options[:coverage] || Teaspoon.configuration.use_coverage
      return false if matched_spec_file?(file)
      true
    end

    def matched_spec_file?(file)
      glob.include?(file)
    end

    def asset_from_file(original)
      filename = original
      Rails.application.config.assets.paths.each do |path|
        filename = filename.gsub(%r(^#{Regexp.escape(path.to_s)}[\/|\\]), "")
      end

      raise Teaspoon::AssetNotServableError.new(filename: filename) if filename == original
      normalize_js_extension(filename)
    end

    def normalize_js_extension(filename)
      filename.gsub(".erb", "").gsub(/(\.js\.coffee|\.coffee|\.es6|\.js\.es6)$/, ".js")
    end

    def glob
      @glob ||= Dir[config.matcher.present? ? Teaspoon.configuration.root.join(config.matcher) : ""].sort!
    end

    def suite_configuration
      config = Teaspoon.configuration.suite_configs[name]
      raise Teaspoon::UnknownSuite.new(name: name) unless config.present?
      config[:instance] ||= Teaspoon::Configuration::Suite.new(name, &config[:block])
    end

    def specs_from_file
      Array(@options[:file]).map do |filename|
        asset_from_file(File.expand_path(Teaspoon.configuration.root.join(filename)))
      end
    end
  end
end
