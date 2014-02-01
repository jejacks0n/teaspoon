require "spec_helper"

describe Teaspoon do

  it "has a configuration property" do
    expect(Teaspoon.configuration).to be(Teaspoon::Configuration)
  end

  describe ".setup" do

    it "yields configuration" do
      config = nil
      Teaspoon.setup { |c| config = c }
      expect(config).to be(Teaspoon::Configuration)
    end

    it "overrides configuration from ENV" do
      Teaspoon.configuration.should_receive(:override_from_env).with(ENV)
      Teaspoon.setup { }
    end

  end

end


describe Teaspoon::Configuration do

  subject { Teaspoon::Configuration }

  after do
    Teaspoon::Configuration.mount_at = "/teaspoon"
    Teaspoon::Configuration.suite_configs.delete("test_suite")
    Teaspoon::Configuration.server = nil
  end

  it "has the default configuration" do
    expect(subject.mount_at).to eq("/teaspoon")
    expect(subject.root).to eq(Rails.root.join('..', '..'))
    expect(subject.asset_paths).to include("spec/javascripts")
    expect(subject.asset_paths).to include("spec/javascripts/stylesheets")
    expect(subject.asset_paths).to include("test/javascripts")
    expect(subject.asset_paths).to include("test/javascripts/stylesheets")
    expect(subject.fixture_path).to eq("spec/javascripts/fixtures")

    expect(subject.driver).to eq("phantomjs")
    expect(subject.driver_options).to eq(nil)
    expect(subject.driver_timeout).to eq(180)
    expect(subject.server).to be_nil
    expect(subject.server_port).to be_nil
    expect(subject.server_timeout).to eq(20)
    expect(subject.formatters).to eq(['dot'])
    expect(subject.fail_fast).to eq(true)
    expect(subject.suppress_log).to eq(false)
    expect(subject.color).to eq(true)

    expect(subject.suite_configs).to be_a(Hash)
    expect(subject.coverage_configs).to be_a(Hash)
  end

  it "allows setting various configuration options" do
    Teaspoon.configuration.mount_at = "/teaspoons_are_awesome"
    expect(subject.mount_at).to eq("/teaspoons_are_awesome")
    Teaspoon.configuration.server = :webrick
    expect(subject.server).to eq(:webrick)
  end

  it "allows defining suite configurations" do
    subject.suite(:test_suite) { }
    expect(subject.suite_configs["test_suite"]).to be_a(Proc)
  end

  it "allows defining coverage configurations" do
    subject.coverage(:test_coverage) { }
    expect(subject.coverage_configs["test_coverage"]).to be_a(Proc)
  end

  describe ".override_from_options" do

    it "allows overriding from options" do
      subject.should_receive(:fail_fast=).with(true)
      subject.should_receive(:driver_timeout=).with(123)
      subject.should_receive(:driver=).with("driver")

      subject.send(:override_from_options, fail_fast: true, driver_timeout: 123, driver: "driver")
    end

  end

  describe ".override_from_env" do

    it "allows overriding from the env" do
      subject.should_receive(:fail_fast=).with(true)
      subject.should_receive(:driver_timeout=).with(123)
      subject.should_receive(:driver=).with("driver")

      subject.send(:override_from_env, "FAIL_FAST" => "true", "DRIVER_TIMEOUT" => "123", "DRIVER" => "driver")
    end

  end

end


describe Teaspoon::Configuration::Suite do

  it "has the default configuration" do
    subject = Teaspoon::Configuration::Suite.new
    expect(subject.matcher).to eq("{spec/javascripts,spec/dummy/app/assets/javascripts/specs}/**/*_spec.{js,js.coffee,coffee,js.coffee.erb}")
    expect(subject.helper).to eq("spec_helper")
    expect(subject.javascripts).to eq(["teaspoon/jasmine"])
    expect(subject.stylesheets).to eq(["teaspoon"])

  end

  it "accepts a block that can override defaults" do
    subject = Teaspoon::Configuration::Suite.new { |s| s.helper = "helper_file" }
    expect(subject.helper).to eq("helper_file")
  end

  it "allows registering hooks" do
    expect(subject.hooks).to eq({})
    subject.hook {}
    expect(subject.hooks['default'].length).to eq(1)
  end

  describe "#normalize_asset_path" do

    it "has the same current default" do
      suite = Teaspoon::Configuration::Suite.new
      expect(suite.normalize_asset_path('blah/something.js.erb')).to eq('blah/something.js')
      expect(suite.normalize_asset_path('blah/something.js.coffee.erb')).to eq('blah/something.js')
      expect(suite.normalize_asset_path('blah/something.js.coffee')).to eq('blah/something.js')
    end

    it "can accept a custom configuration" do
      suite = Teaspoon::Configuration::Suite.new
      suite.normalize_asset_path = lambda {|filename| filename.gsub('.erb', '').gsub(/(\.es6)$/, ".js") }

      expect(suite.normalize_asset_path('blah/something.es6')).to eq('blah/something.js')
    end

  end

end


describe Teaspoon::Configuration::Coverage do

  it "has the default configuration" do
    subject = Teaspoon::Configuration::Coverage.new
    expect(subject.reports).to eq(["text-summary"])
    expect(subject.ignored).to eq([%r{/lib/ruby/gems/}, %r{/vendor/assets/}, %r{/support/}, %r{/(.+)_helper.}])
    expect(subject.output_path).to eq("coverage")
    expect(subject.statement_threshold).to be_nil
    expect(subject.function_threshold).to be_nil
    expect(subject.branch_threshold).to be_nil
    expect(subject.line_threshold).to be_nil
  end

  it "accepts a block that can override defaults" do
    subject = Teaspoon::Configuration::Coverage.new { |s| s.reports = "report_format" }
    expect(subject.reports).to eq("report_format")
  end

end
