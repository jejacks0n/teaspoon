module Teaspoon
  class Suite

    attr_accessor :config, :name

    def self.all
      Teaspoon.configuration.suites.keys.map { |suite| Teaspoon::Suite.new(suite: suite) }
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

    def stylesheets
      config.stylesheets
    end

    def helper
      config.helper
    end

    def javascripts
      [core_javascripts, spec_javascripts].flatten
    end

    def core_javascripts
      config.javascripts
    end

    def js_config
      config.js_config
    end

    def boot_partial
      config.boot_partial
    end

    def spec_javascripts
      [helper, specs].flatten
    end

    def spec_javascripts_for_require
      specs.map { |path|
        file_without_ext = path.split('.').first
        "#{file_without_ext}"
      }
    end

    def suites
      {all: Teaspoon.configuration.suites.keys, active: name}
    end

    def spec_files
      glob.map { |file| {path: file, name: asset_from_file(file)} }
    end

    def link(params = {})
      query = "?#{params.to_query}" if params.present?
      [Teaspoon.configuration.mount_at, name, query].compact.join('/')
    end

    def instrument_file?(file)
      return false if include_spec?(file)
      for ignored in @config.no_coverage
        if ignored.is_a?(String)
          return false if File.basename(file) == ignored
        elsif ignored.is_a?(Regexp)
          return false if file =~ ignored
        end
      end
      true
    end

    def include_spec?(file)
      glob.include?(file)
    end

    def include_spec_for?(file)
      return file if glob.include?(file)
      paths = glob.select { |path| path.include?(file)  }
      return paths unless paths.empty?
      false
    end

    def run_hooks(group = :default)
      config.hooks[group.to_s].each do |hook|
        hook.call
      end
    end

    protected

    def specs
      files = specs_from_file
      return files unless files.empty?
      glob.map { |file| asset_from_file(file) }
    end

    def glob
      @glob ||= Dir[config.matcher.present? ? Teaspoon.configuration.root.join(config.matcher) : ""]
    end

    def suite_configuration
      config = Teaspoon.configuration.suites[name]
      raise Teaspoon::UnknownSuite unless config.present?
      Teaspoon::Configuration::Suite.new(&config)
    end

    def specs_from_file
      Array(@options[:file]).map do |filename|
        asset_from_file(File.expand_path(Teaspoon.configuration.root.join(filename)))
      end
    end

    def asset_from_file(original)
      filename = original
      Rails.application.config.assets.paths.each do |path|
        path = path.to_s
        filename = filename.gsub(%r(^#{Regexp.escape(path)}[\/|\\]), "")
      end
      raise Teaspoon::AssetNotServable, "#{filename} is not within an asset path" if filename == original
      filename.gsub(/(\.js\.coffee|\.coffee)$/, ".js")
    end
  end
end
