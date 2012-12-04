class Teabag::Suite

  attr_accessor :config
  delegate :stylesheets, :helper, to: :config

  def initialize(name = nil)
    @config = configuration_or_default(name || :default)
  end

  def javascripts
    [config.javascripts, config.helper, specs].flatten
  end

  def specs
    Dir[config.matcher.present? ? Teabag.configuration.root.join(config.matcher) : ""].map do |filename|
      asset_path_from_filename(File.expand_path(filename))
    end
  end

  private

  def configuration_or_default(name)
    suite = Teabag.configuration.suites[name.to_s]
    proc = suite.present? ? suite : nil
    Teabag::Configuration::Suite.new(&proc)
  end

  def asset_path_from_filename(filename)
    Rails.application.config.assets.paths.each do |path|
      filename.gsub!(%r(^#{path}[\/|\\]), "")
    end
    filename
  end
end
