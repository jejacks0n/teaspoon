require "spec_helper"

describe Teabag::Suite do

  before do
    Teabag.configuration.stub(:suites).and_return "default" => proc{}
  end

  describe ".all" do

    it "returns all the suites" do
      Teabag.configuration.stub(:suites).and_return "default" => proc{}, "foo" => proc{}
      results = Teabag::Suite.all
      expect(results.first).to be_a(Teabag::Suite)
      expect(results.length).to be(2)
      expect(results.first.name).to eq("default")
      expect(results.last.name).to eq("foo")
    end

  end

  describe ".resolve_spec_for" do

    it "return a hash with the suite name and path" do
      results = Teabag::Suite.resolve_spec_for("fixture_spec")
      expect(results[:suite]).to eq("default")
      expect(results[:path]).to include("base/fixture_spec.")
    end

  end

  describe "#initialize" do

    it "uses default suite configuration" do
      expect(subject.config.helper).to eq("spec_helper")
    end

    it "accepts a suite configuration name" do
      Teabag.configuration.should_receive(:suites).and_return "test" => proc{ |s| s.helper = "helper_file" }
      subject = Teabag::Suite.new({suite: :test})
      expect(subject.config.helper).to eq("helper_file")
    end

  end

  describe "#name" do

    it "returns the name of the suite" do
      expect(subject.name).to eql("default")
    end

  end

  describe "#stylesheets" do

    it "returns an array of stylesheets" do
      expect(subject.stylesheets).to include("teabag")
    end

  end

  describe "#helper" do

    it "returns the javascript helper" do
      expect(subject.helper).to eq("spec_helper")
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

  describe "#include_spec?" do

    it "returns true if the spec was found" do
      files = subject.send(:glob)
      expect(subject.include_spec?(files.first)).to eq(true)
    end

    it "returns true if the file matches the spec" do
      expect(subject.include_spec?("spec_helper")).to eq(true)
    end

    it "returns true if the source matches the spec" do
      expect(subject.include_spec?(nil, "spec_helper")).to eq(true)
    end

    it "returns false if no match was found" do
      expect(subject.include_spec?("foo", "bar")).to eq(false)
    end

  end

  describe "#include_spec_for?" do

    it "returns the spec if an exact match was found" do
      files = subject.send(:glob)
      expect(subject.include_spec_for?(files.first)).to eq(files.first)
    end

    it "returns the spec when the file name looks like it could be a match" do
      files = subject.send(:glob)
      expect(subject.include_spec_for?('fixture_spec')).to eq(files.first)
    end

    it "returns false if a matching spec isn't found" do
      expect(subject.include_spec_for?('_not_a_match_')).to eq(false)
    end

  end

  describe "#specs" do

    it "converts file names that are in registered asset paths into usable asset urls" do
      Teabag.configuration.should_receive(:suites).and_return "default" => proc{ |s| s.matcher = Teabag::Engine.root.join("spec/javascripts/support/*.*") }
      expect(subject.send(:specs)).to include("support/support.js")
    end

    it "raises an AssetNotServable exception if the file can't be served by sprockets" do
      Teabag.configuration.should_receive(:suites).and_return "default" => proc{ |s| s.matcher = __FILE__ }
      expect{ subject.send(:specs) }.to raise_error(Teabag::AssetNotServable, "#{__FILE__} is not within an asset path")
    end

  end

end
