require "spec_helper"

describe Teaspoon::Suite do
  let(:suite_config) { { block: proc { |c| c.javascripts = ["foo"] } } }

  before do
    allow(Teaspoon.configuration).to receive(:suite_configs).and_return("default" => suite_config)
  end

  describe ".all" do
    before do
      Teaspoon::Suite.instance_variable_set(:@all, nil)
      suites = { "default" => suite_config, "foo" => suite_config }
      allow(Teaspoon.configuration).to receive(:suite_configs).and_return(suites)
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
      expect(result[:path].first).to include("teaspoon/fixture_spec.")
    end

    it "returns a hash with the suite name and an array of paths if a directory is given" do
      result = Teaspoon::Suite.resolve_spec_for("reporters")
      expect(result[:suite]).to eq("default")
      dirs = ["reporters/console_spec.", "reporters/html/base_view_spec.", "reporters/html/failure_view_spec."]
      expect(dirs.all? { |path| result[:path].grep(/#{path}/)[0] }).to be_truthy
    end

    it "returns false if the spec wasn't found" do
      expect(Teaspoon::Suite.resolve_spec_for("foo")).to be_falsey
    end
  end

  describe "#initialize" do
    it "uses default suite configuration" do
      expect(subject.name).to eq("default")
      expect(subject.config.helper).to eq("spec_helper")
    end

    it "accepts a suite in the options" do
      suite = { "test" => { block: proc { |s| s.helper = "helper_file" } } }
      expect(Teaspoon.configuration).to receive(:suite_configs).and_return(suite)
      subject = Teaspoon::Suite.new(suite: :test)
      expect(subject.name).to eql("test")
      expect(subject.config.helper).to eq("helper_file")
    end
  end

  describe "#spec_files" do
    it "returns an array of hashes with the filename and the asset name" do
      file = Teaspoon::Engine.root.join("spec/javascripts/teaspoon/base/reporters/console_spec.js").to_s
      expect(subject).to receive(:glob).and_return([file])
      expect(subject.spec_files[0]).to eql(path: file, name: "teaspoon/base/reporters/console_spec.js")
    end

    it "raises an exception if the file isn't servable (in an asset path)" do
      expect(subject).to receive(:glob).and_return(["/foo"])
      expect { subject.spec_files[0] }.to raise_error(
        Teaspoon::AssetNotServableError,
        "Unable to serve asset: expected \"/foo\" to be within a registered asset path."
      )
    end
  end

  describe "#spec_assets" do
    subject { described_class.new(coverage: true) }

    it "returns an array of assets" do
      result = subject.spec_assets
      expect(result).to include("spec_helper.self.js?body=1&instrument=1")
      expect(result).to include("teaspoon/reporters/console_spec.self.js?body=1")
    end

    it "returns just a file if one was requested" do
      subject.instance_variable_set(:@options, file: "spec/javascripts/foo.js")
      result = subject.spec_assets(false)
      expect(result).to eql(["foo.js"])
    end

    it "returns the asset tree (all dependencies resolved) if we want coverage" do
      result = subject.spec_assets(true)

      expect(result).to include("teaspoon/reporters/console_spec.self.js?body=1") # Specs do not get instrumentation
      expect(result).to include("support/json2.self.js?body=1&instrument=1")
      expect(result).to include("spec_helper.self.js?body=1&instrument=1")
      expect(result).to include("driver/phantomjs/runner.self.js?body=1&instrument=1")
    end

    it "returns only the top level assets in the asset tree if config/expand_assets is set to false" do
      allow(subject.config).to receive(:expand_assets).and_return(false)
      result = subject.spec_assets(true)
      expect(result.any? { |file| file =~ /body=1/ }).to eq(false)
    end
  end

  describe "#include_spec_for?" do
    it "returns the spec if an exact match was found" do
      files = subject.send(:glob)
      expect(subject.include_spec_for?(files.first)).to eq(files.first)
    end

    it "returns a list of specs when the file name looks like it could be a match" do
      files = subject.include_spec_for?("fixture_spec")
      expect(files.any? { |file| file.include?("fixture_spec.coffee") }).to be_truthy
    end

    it "returns false if a matching spec isn't found" do
      expect(subject.include_spec_for?("_not_a_match_")).to eq(false)
    end
  end
end
