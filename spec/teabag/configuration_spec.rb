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

    it "allows overriding of fail_fast and suppress_log from the env" do
      Teabag.setup { |c| config = c }
      ENV["suppress_log"] = "true"
      ENV["fail_fast"] = "false"
      Teabag.send(:override_from_env)
      expect(Teabag.configuration.suppress_log).to eq(true)
      expect(Teabag.configuration.fail_fast).to eq(false)
      ENV["suppress_log"] = nil
      ENV["fail_fast"] = nil
    end

  end

end


describe Teabag::Configuration do

  subject { Teabag::Configuration }

  after do
    Teabag::Configuration.mount_at = "/teabag"
    Teabag::Configuration.suites = {}
  end

  it "has the default configuration" do
    expect(subject.mount_at).to eq("/teabag")
    expect(subject.asset_paths).to include("spec/javascripts")
    expect(subject.asset_paths).to include("spec/javascripts/stylesheets")
    expect(subject.fixture_path).to eq("spec/javascripts/fixtures")
    expect(subject.server_timeout).to eq(20)
    expect(subject.fail_fast).to eq(true)
    expect(subject.suppress_log).to eq(false)
    expect(subject.suites).to eq({})
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
    expect(subject.matcher).to eq("{app/assets,lib/assets/,spec/javascripts}/**/*_spec.{js,js.coffee,coffee}")
    expect(subject.helper).to eq("spec_helper")
    expect(subject.javascripts).to eq(["teabag-jasmine"])
    expect(subject.stylesheets).to eq(["teabag"])
  end

  it "accepts a block that can override defaults" do
    subject = Teabag::Configuration::Suite.new { |s| s.helper = "helper_file" }
    expect(subject.helper).to eq("helper_file")
  end

end
