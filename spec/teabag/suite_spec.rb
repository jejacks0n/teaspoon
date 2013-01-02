require "spec_helper"

describe Teabag::Suite do

  before do
    Teabag.configuration.suite(:default) {}
  end

  after do
    Teabag.configuration.suites = {}
  end

  describe ".new" do

    it "uses default suite configuration" do
      expect(subject.config.helper).to eq("spec_helper")
    end

    it "accepts a suite configuration name" do
      Teabag.configuration.suite(:test) { |s| s.helper = "helper_file" }
      subject = Teabag::Suite.new(:test)
      expect(subject.config.helper).to eq("helper_file")
    end

  end

  describe "#specs" do

    it "converts file names that are in registered asset paths into usable asset urls" do
      Teabag.configuration.suite { |s| s.matcher = Teabag::Engine.root.join("spec/javascripts/support/*.*") }
      expect(subject.specs).to include("support/support.js")
    end

    it "raises an AssetNotServable exception if the file can't be served by sprockets" do
      Teabag.configuration.suite { |s| s.matcher = __FILE__ }
      expect { subject.specs }.to raise_error(Teabag::AssetNotServable, "#{__FILE__} is not within an asset path")
    end

  end

  describe "#javascripts" do

    it "returns an array of javascripts" do
      results = subject.javascripts
      expect(results).to include("teabag-jasmine")
      expect(results).to include("spec_helper")
    end

  end

  describe "#core_javascripts" do

    it "returns an array of javascripts" do
      results = subject.core_javascripts
      expect(results).to eql(["teabag-jasmine"])
    end

  end

  describe "#spec_javascripts" do

    it "returns an array of javascripts" do
      results = subject.spec_javascripts
      expect(results).to include("spec_helper")
      expect(results).to include("teabag/base/reporters/console_spec.js")
    end

  end


  describe "#stylesheets" do

    it "returns an array of stylesheets" do
      expect(subject.stylesheets).to include("teabag")
    end

  end

  describe "#suites" do

    it "returns as hash with expected results" do
      expect(subject.suites).to eql({all: ["default"], active: "default"})
    end

  end

end
