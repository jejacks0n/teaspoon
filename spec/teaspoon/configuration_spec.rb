require "spec_helper"

describe Teaspoon do

  subject { Teaspoon }

  it "has a configuration property" do
    expect(subject.configuration).to be(Teaspoon::Configuration)
  end

  describe ".configure" do

    it "yields configuration" do
      config = nil
      subject.configure { |c| config = c }
      expect(config).to be(Teaspoon::Configuration)
    end

    it "sets configured to true" do
      subject.configured = false
      subject.configure { }
      expect(subject.configured).to be_true
    end

    it "overrides configuration from ENV" do
      subject.configuration.should_receive(:override_from_env).with(ENV)
      subject.configure { }
    end

  end

  describe ".setup" do

    it "calls configure" do
      subject.should_receive(:configure).with(&block = proc{})
      subject.setup(&block)
    end

  end

end


describe Teaspoon::Configuration do

  subject { Teaspoon::Configuration }

  before do
    @orig_root = subject.root
    @orig_asset_paths = subject.asset_paths
    @orig_formatters = subject.formatters
  end

  after do
    subject.mount_at = "/teaspoon"
    subject.suite_configs.delete("test_suite")
    subject.server = nil
    subject.root = @orig_root
    subject.asset_paths = @orig_asset_paths
    subject.formatters = @orig_formatters
  end

  it "has the default configuration" do
    expect(subject.mount_at).to eq("/teaspoon")
    expect(subject.root).to eq(Rails.root.join('..', '..'))
    expect(subject.asset_paths).to include("spec/javascripts")
    expect(subject.asset_paths).to include("spec/javascripts/stylesheets")
    expect(subject.fixture_paths).to eq(["spec/javascripts/fixtures", "test/javascripts/fixtures"])

    expect(subject.driver).to eq("phantomjs")
    expect(subject.driver_options).to be_nil
    expect(subject.driver_timeout).to eq(180)
    expect(subject.server).to be_nil
    expect(subject.server_port).to be_nil
    expect(subject.server_timeout).to eq(20)
    expect(subject.formatters).to eq(['dot'])
    expect(subject.use_coverage).to be_nil
    expect(subject.fail_fast).to be_true
    expect(subject.suppress_log).to be_false
    expect(subject.color).to be_true

    expect(subject.suite_configs).to be_a(Hash)
    expect(subject.coverage_configs).to be_a(Hash)
  end

  it "allows setting various configuration options" do
    subject.mount_at = "/teaspoons_are_awesome"
    expect(subject.mount_at).to eq("/teaspoons_are_awesome")
    subject.server = :webrick
    expect(subject.server).to eq(:webrick)
  end

  it "allows defining suite configurations" do
    subject.suite(:test_suite) { }
    expect(subject.suite_configs["test_suite"][:block]).to be_a(Proc)
    expect(subject.suite_configs["test_suite"][:instance]).to be_a(Teaspoon::Configuration::Suite)
  end

  it "allows defining coverage configurations" do
    subject.coverage(:test_coverage) { }
    expect(subject.coverage_configs["test_coverage"][:block]).to be_a(Proc)
    expect(subject.coverage_configs["test_coverage"][:instance]).to be_a(Teaspoon::Configuration::Coverage)
  end

  describe ".root=" do

    it "forces the path provided into a Pathname" do
      subject.root = "/path"
      expect(subject.root).to be_a(Pathname)
    end

  end

  describe ".formatters" do

    it "returns the default dot formatter if nothing was set" do
      expect(subject.formatters).to eq(["dot"])
    end

    it "returns an array of formatters if they were comma separated" do
      subject.formatters = "dot,swayze_or_oprah"
      expect(subject.formatters).to eq(["dot", "swayze_or_oprah"])
    end

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

  subject { Teaspoon::Configuration::Suite.new &(@suite || proc{}) }

  it "has the default configuration" do
    expect(subject.matcher).to eq("{spec/javascripts,spec/dummy/app/assets/javascripts/specs}/**/*_spec.{js,js.coffee,coffee,js.coffee.erb}")
    expect(subject.helper).to eq("spec_helper")
    expect(subject.javascripts).to eq(["jasmine/1.3.1", "teaspoon/jasmine"])
    expect(subject.stylesheets).to eq(["teaspoon"])
    expect(subject.no_coverage).to eq([%r{/lib/ruby/gems/}, %r{/vendor/assets/}, %r{/support/}, %r{/(.+)_helper.}])
  end

  it "accepts a block that can override defaults" do
    @suite = proc{ |s| s.helper = "helper_file" }
    expect(subject.helper).to eq("helper_file")
  end

  it "allows registering hooks" do
    expect(subject.hooks).to eq({})
    subject.hook {}
    expect(subject.hooks['default'].length).to eq(1)
  end

  describe "specifying a framework" do

    it "allows specifying mocha with a version" do
      @suite = proc{ |s| s.use_framework :mocha, "1.10.0" }
      expect(subject.javascripts).to eq(["mocha/1.10.0", "teaspoon-mocha"])
    end

    it "handles qunit specifically to set matcher and helper" do
      @suite = proc{ |s| s.use_framework :qunit }
      expect(subject.javascripts).to eq(["qunit/1.14.0", "teaspoon-qunit"])
      expect(subject.matcher).to eq("{test/javascripts,app/assets}/**/*_test.{js,js.coffee,coffee}")
      expect(subject.helper).to eq("test_helper")
    end

    describe "exceptions" do

      it "shows an error for unknown frameworks" do
        @suite = proc{ |s| s.use_framework :foo }
        expect{ subject }.to raise_error Teaspoon::UnknownFramework, "Unknown framework \"foo\""
      end

      it "shows an error for unknown versions" do
        @suite = proc{ |s| s.use_framework :qunit, "666" }
        expect{ subject }.to raise_error Teaspoon::UnknownFramework, "Unknown framework \"qunit\" with version 666 -- available versions 1.12.0, 1.14.0"
      end

    end

  end

end


describe Teaspoon::Configuration::Coverage do

  subject { Teaspoon::Configuration::Coverage.new &(@coverage || proc{}) }

  it "has the default configuration" do
    expect(subject.reports).to eq(["text-summary"])
    expect(subject.output_path).to eq("coverage")
    expect(subject.statements).to be_nil
    expect(subject.functions).to be_nil
    expect(subject.branches).to be_nil
    expect(subject.lines).to be_nil
  end

  it "accepts a block that can override defaults" do
    @coverage = proc{ |s| s.reports = "report_format" }
    expect(subject.reports).to eq("report_format")
  end

end
