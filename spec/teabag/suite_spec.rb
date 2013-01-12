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
      subject = Teabag::Suite.new({suite: :test})
      expect(subject.config.helper).to eq("helper_file")
    end

  end

  describe "#stylesheets" do

    it "returns an array of stylesheets" do
      expect(subject.stylesheets).to include("teabag")
    end

  end

  describe "#name" do

    it "returns the name of the suite" do
      expect(subject.name).to eql("default")
    end

  end

  describe "#javascripts" do

    it "returns an array of all javascripts" do
      results = subject.javascripts
      expect(results).to include("teabag-jasmine")
      expect(results).to include("spec_helper")
    end

  end

  describe "#core_javascripts" do

    it "returns an array of core javascripts" do
      results = subject.core_javascripts
      expect(results).to eql(["teabag-jasmine"])
    end

  end

  describe "#spec_javascripts" do

    it "returns an array of spec javascripts" do
      results = subject.spec_javascripts
      expect(results).to include("spec_helper")
      expect(results).to include("teabag/base/reporters/console_spec.js")
    end

    it "returns the file requested if one was passed" do
      subject = Teabag::Suite.new({file: "spec/javascripts/foo.js"})
      results = subject.spec_javascripts
      expect(results).to eql(["spec_helper", "foo.js"])
    end

  end

  describe "#suites" do

    it "returns as hash with expected results" do
      expect(subject.suites).to eql({all: ["default"], active: "default"})
    end

  end

  describe "#spec_files" do

    it "returns an array of hashes with the filename and the asset name" do
      file = Teabag::Engine.root.join("spec/javascripts/teabag/base/reporters/console_spec.js").to_s
      subject.should_receive(:glob).and_return([file])
      expect(subject.spec_files[0]).to eql({path: file, name: "teabag/base/reporters/console_spec.js"})
    end

  end

  describe "#link" do

    it "returns a link for the specific suite" do
      expect(subject.link).to eql("/teabag/default")
    end

    it "returns a link with added params" do
      expect(subject.link(file: ["file1", "file2"], grep: "foo")).to eql("/teabag/default/?file%5B%5D=file1&file%5B%5D=file2&grep=foo")
    end

  end

  describe "#specs" do

    it "converts file names that are in registered asset paths into usable asset urls" do
      Teabag.configuration.suite { |s| s.matcher = Teabag::Engine.root.join("spec/javascripts/support/*.*") }
      expect(subject.send(:specs)).to include("support/support.js")
    end

    it "raises an AssetNotServable exception if the file can't be served by sprockets" do
      Teabag.configuration.suite { |s| s.matcher = __FILE__ }
      expect { subject.send(:specs) }.to raise_error(Teabag::AssetNotServable, "#{__FILE__} is not within an asset path")
    end

  end

end
