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

    it "returns an array of spec files based on the matcher" do
      Teabag.configuration.suite { |s| s.matcher = __FILE__ }
      expect(subject.specs).to eq([__FILE__])
    end

    it "converts file names that are in registered asset paths into usable asset urls" do
      Teabag.configuration.suite { |s| s.matcher = Teabag::Engine.root.join("spec/javascripts/support/*.*") }
      expect(subject.specs).to eq(["support/support.js.coffee"])
    end

  end

  describe "#javascripts" do

    it "returns an array of javascripts" do
      expect(subject.javascripts).to include("teabag-jasmine")
    end

  end

  describe "#stylesheets" do

    it "returns an array of stylesheets" do
      expect(subject.stylesheets).to include("teabag")
    end

  end

end
