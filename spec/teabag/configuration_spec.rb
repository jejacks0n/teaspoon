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

end


describe Teabag::Configuration do

  subject { Teabag::Configuration }

  after do
    Teabag::Configuration.mount_at = "/teabag"
    Teabag::Configuration.suites = {}
  end

  it "has the default configuration" do
    expect(subject.mount_at).to eq("/teabag")
    expect(subject.asset_paths).to eq(["spec/javascripts", "spec/javascripts/stylesheets"])
    expect(subject.fixture_path).to eq("spec/javascripts/fixtures")
    expect(subject.server_timeout).to eq(20)
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
    expect(subject.helper).to eq("spec_helper.js")
    expect(subject.javascripts).to eq(["teabag-jasmine"])
    expect(subject.stylesheets).to eq(["teabag"])
  end

  it "accepts a block that can override defaults" do
    subject = Teabag::Configuration::Suite.new { |s| s.helper = "helper_file.js" }
    expect(subject.helper).to eq("helper_file.js")
  end

end
