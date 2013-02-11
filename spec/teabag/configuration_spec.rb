require "spec_helper"

describe Teabag do

  it "has a configuration property" do
    expect(Teabag.configuration).to be(Teabag::Configuration)
  end

  describe ".setup" do

    it "yields configuration" do
      config = nil
      Teabag.setup { |c| config = c }
      expect(config).to be(Teabag::Configuration)
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
      Teabag.configuration.should_receive(:suppress_log=).with(true)
      Teabag.configuration.should_receive(:fail_fast=).with(false)
      Teabag.configuration.should_receive(:formatters=).with("something")
      Teabag.send(:override_from_env)
    end

  end

end


describe Teabag::Configuration do

  subject { Teabag::Configuration }

  after do
    Teabag::Configuration.mount_at = "/teabag"
    Teabag::Configuration.suites.delete("test_suite")
  end

  it "has the default configuration" do
    expect(subject.mount_at).to eq("/teabag")
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
  end

  it "allows setting various configuration options" do
    Teabag.configuration.mount_at = "/teabags_are_awesome"
    expect(subject.mount_at).to eq("/teabags_are_awesome")
  end

  it "allows defining suites" do
    subject.suite(:test_suite) { }
    expect(subject.suites["test_suite"]).to be_a(Proc)
  end

end


describe Teabag::Configuration::Suite do

  it "has the default configuration" do
    subject = Teabag::Configuration::Suite.new
    expect(subject.matcher).to eq("{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}")
    expect(subject.helper).to eq("spec_helper")
    expect(subject.javascripts).to eq(["teabag-jasmine"])
    expect(subject.stylesheets).to eq(["teabag"])
  end

  it "accepts a block that can override defaults" do
    subject = Teabag::Configuration::Suite.new { |s| s.helper = "helper_file" }
    expect(subject.helper).to eq("helper_file")
  end

end
