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

  end

  describe ".override_from_env" do

    after do
      ENV["SUPPRESS_LOG"] = nil
      ENV["FAIL_FAST"] = nil
      ENV["FORMATTERS"] = nil
    end

    it "allows overriding of fail_fast and suppress_log from the env" do
      ENV["SUPPRESS_LOG"] = "true"
      ENV["FAIL_FAST"] = "false"
      ENV["FORMATTERS"] = "something"
      Teaspoon.configuration.should_receive(:suppress_log=).with(true)
      Teaspoon.configuration.should_receive(:fail_fast=).with(false)
      Teaspoon.configuration.should_receive(:formatters=).with("something")
      Teaspoon.send(:override_from_env)
    end

  end

end


describe Teaspoon::Configuration do

  subject { Teaspoon::Configuration }

  after do
    Teaspoon::Configuration.mount_at = "/teaspoon"
    Teaspoon::Configuration.suites.delete("test_suite")
    Teaspoon::Configuration.server = nil
  end

  it "has the default configuration" do
    expect(subject.mount_at).to eq("/teaspoon")
    expect(subject.context).to eq(nil)
    expect(subject.asset_paths).to include("spec/javascripts")
    expect(subject.asset_paths).to include("spec/javascripts/stylesheets")
    expect(subject.fixture_path).to eq("spec/javascripts/fixtures")
    expect(subject.formatters).to eq(['dot'])
    expect(subject.server_timeout).to eq(20)
    expect(subject.fail_fast).to eq(true)
    expect(subject.suppress_log).to eq(false)
    expect(subject.suites).to be_a(Hash)
    expect(subject.coverage).to eq(false)
    expect(subject.coverage_reports).to eq(["text-summary"])
    expect(subject.coverage_output_dir).to eq("coverage")
    expect(subject.server).to be_nil
    expect(subject.statements_coverage_threshold).to be_nil
    expect(subject.functions_coverage_threshold).to be_nil
    expect(subject.branches_coverage_threshold).to be_nil
    expect(subject.lines_coverage_threshold).to be_nil
    expect(subject.timeout).to eq(180)
  end

  it "allows setting various configuration options" do
    Teaspoon.configuration.mount_at = "/teaspoons_are_awesome"
    expect(subject.mount_at).to eq("/teaspoons_are_awesome")
    Teaspoon.configuration.server = :webrick
    expect(subject.server).to eq(:webrick)
  end

  it "allows defining suites" do
    subject.suite(:test_suite) { }
    expect(subject.suites["test_suite"]).to be_a(Proc)
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


  it "allows creating hooks" do
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
