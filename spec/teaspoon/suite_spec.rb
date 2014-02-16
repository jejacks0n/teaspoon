require "spec_helper"

describe Teaspoon::Suite do

  before do
    Teaspoon.configuration.stub(:suite_configs).and_return("default" => {block: proc{}})
  end

  describe ".all" do

    before do
      Teaspoon::Suite.instance_variable_set(:@all, nil)
      Teaspoon.configuration.stub(:suite_configs).and_return("default" => {block: proc{}}, "foo" => {block: proc{}})
    end

    it "returns all the suites" do
      result = Teaspoon::Suite.all
      expect(result.first).to be_a(Teaspoon::Suite)
      expect(result.length).to be(2)
      expect(result.first.name).to eq("default")
      expect(result.last.name).to eq("foo")
    end

  end

  describe ".resolve_spec_for" do

    it "return a hash with the suite name and path" do
      result = Teaspoon::Suite.resolve_spec_for("fixture_spec")
      expect(result[:suite]).to eq("default")
      expect(result[:path].first).to include("base/fixture_spec.")
    end

    it "returns a hash with the suite name and an array of paths if a directory is given" do
      result = Teaspoon::Suite.resolve_spec_for("base")
      expect(result[:suite]).to eq("default")
      dirs = ["base/fixture_spec.", "base/runner_spec.", "base/teaspoon_spec"]
      expect(dirs.all? { |path| result[:path].grep(/#{path}/)[0] }).to be_true
    end

  end

  describe "#initialize" do

    it "uses default suite configuration" do
      expect(subject.name).to eq("default")
      expect(subject.config.helper).to eq("spec_helper")
    end

    it "accepts a suite in the options" do
      Teaspoon.configuration.should_receive(:suite_configs).and_return("test" => {block: proc{ |s| s.helper = "helper_file" }})
      subject = Teaspoon::Suite.new(suite: :test)
      expect(subject.name).to eql("test")
      expect(subject.config.helper).to eq("helper_file")
    end

  end

  describe "#spec_files" do

    it "returns an array of hashes with the filename and the asset name" do
      file = Teaspoon::Engine.root.join("spec/javascripts/teaspoon/base/reporters/console_spec.js").to_s
      subject.should_receive(:glob).and_return([file])
      expect(subject.spec_files[0]).to eql(path: file, name: "teaspoon/base/reporters/console_spec.js")
    end

    it "raises an exception if the file isn't servable (in an asset path)" do
      subject.should_receive(:glob).and_return(["/foo"])
      expect { subject.spec_files[0] }.to raise_error Teaspoon::AssetNotServable
    end

  end

  describe "#spec_assets" do

    it "returns an array of assets" do
      result = subject.spec_assets
      expect(result).to include("spec_helper.js?body=1")
      expect(result).to include("teaspoon/base/reporters/console_spec.js?body=1")
    end

    it "returns just a file if one was requests" do
      subject.instance_variable_set(:@options, file: "spec/javascripts/foo.js")
      result = subject.spec_assets(false)
      expect(result).to eql(["foo.js"])
    end

    it "returns the asset tree (all dependencies resolved) if we want coverage" do
      subject.instance_variable_set(:@options, coverage: true)
      result = subject.spec_assets(true)
      expect(result).to include("support/json2.js?body=1")
      expect(result).to include("spec_helper.js?body=1")
      expect(result).to include("drivers/phantomjs/runner.js?body=1&instrument=1")
    end

  end

  describe "#include_spec?" do

    it "returns true if the spec was found in the suite" do
      files = subject.send(:glob)
      expect(subject.include_spec?(files.first)).to eq(true)
    end

  end

  describe "#include_spec_for?" do

    it "returns the spec if an exact match was found" do
      files = subject.send(:glob)
      expect(subject.include_spec_for?(files.first)).to eq(files.first)
    end

    it "returns a list of specs when the file name looks like it could be a match" do
      expect( subject.include_spec_for?('fixture_spec').any? { |file| file.include?('fixture_spec.coffee') }).to be_true
    end

    it "returns false if a matching spec isn't found" do
      expect(subject.include_spec_for?('_not_a_match_')).to eq(false)
    end

  end

end
