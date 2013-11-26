require "spec_helper"

describe Teaspoon::Suite do

  before do
    Teaspoon.configuration.stub(:suites).and_return "default" => proc{}
  end

  describe ".all" do

    it "returns all the suites" do
      Teaspoon.configuration.stub(:suites).and_return "default" => proc{}, "foo" => proc{}
      results = Teaspoon::Suite.all
      expect(results.first).to be_a(Teaspoon::Suite)
      expect(results.length).to be(2)
      expect(results.first.name).to eq("default")
      expect(results.last.name).to eq("foo")
    end

  end

  describe ".resolve_spec_for" do

    it "return a hash with the suite name and path" do
      results = Teaspoon::Suite.resolve_spec_for("fixture_spec")
      expect(results[:suite]).to eq("default")
      expect(results[:path].first).to include("base/fixture_spec.")
    end

    it "returns a hash with the suite name and an array of paths if a directory is given" do
      results = Teaspoon::Suite.resolve_spec_for("base")
      expect(results[:suite]).to eq("default")
      dirs = ["base/fixture_spec.", "base/runner_spec.", "base/teaspoon_spec"]
      expect(dirs.all? { |path| results[:path].grep(/#{path}/)[0] }).to be_true
    end

  end

  describe "#initialize" do

    it "uses default suite configuration" do
      expect(subject.config.helper).to eq("spec_helper")
    end

    it "accepts a suite configuration name" do
      Teaspoon.configuration.should_receive(:suites).and_return "test" => proc{ |s| s.helper = "helper_file" }
      subject = Teaspoon::Suite.new({suite: :test})
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
      expect(subject.stylesheets).to include("teaspoon")
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
      expect(results).to include("teaspoon-jasmine")
      expect(results).to include("spec_helper")
    end

  end

  describe "#core_javascripts" do

    it "returns an array of core javascripts" do
      results = subject.core_javascripts
      expect(results).to eql(["teaspoon-jasmine"])
    end

  end

  describe "#spec_javascripts" do

    it "returns an array of spec javascripts" do
      results = subject.spec_javascripts
      expect(results).to include("spec_helper")
      expect(results).to include("teaspoon/base/reporters/console_spec.js")
    end

    it "returns the file requested if one was passed" do
      subject = Teaspoon::Suite.new({file: "spec/javascripts/foo.js"})
      results = subject.spec_javascripts
      expect(results).to eql(["spec_helper", "foo.js"])
    end

  end

  describe "#spec_javascripts_for_require" do

    let(:files) { ['/path/file1.js.coffee', 'path/file2.coffee', 'file3.coffee.erb', 'file4.js.erb' ] }

    before do
      subject.should_receive(:specs).and_return(files)
    end

    it 'returns an array of spec javascripts without .js and Teaspoon prefix' do
      expect( subject.spec_javascripts_for_require ).to eq(['/path/file1', 'path/file2', 'file3', 'file4'])
    end

  end

  describe "#suites" do

    it "returns as hash with expected results" do
      expect(subject.suites).to eql({all: ["default"], active: "default"})
    end

  end

  describe "#spec_files" do

    it "returns an array of hashes with the filename and the asset name" do
      file = Teaspoon::Engine.root.join("spec/javascripts/teaspoon/base/reporters/console_spec.js").to_s
      subject.should_receive(:glob).and_return([file])
      expect(subject.spec_files[0]).to eql({path: file, name: "teaspoon/base/reporters/console_spec.js"})
    end

  end

  describe "#link" do

    it "returns a link for the specific suite" do
      expect(subject.link).to eql("/teaspoon/default")
    end

    it "returns a link with added params" do
      expect(subject.link(file: ["file1", "file2"], grep: "foo")).to eql("/teaspoon/default/?file%5B%5D=file1&file%5B%5D=file2&grep=foo")
    end

  end

  describe "#instrument_file?" do

    before do
      Teaspoon.configuration.stub(:suites).and_return "default" => proc{ |s| s.no_coverage = ["file_", /some\/other/] }
      subject.stub(:include_spec?).and_return(false)
    end

    it "returns false if the file is a spec" do
      subject.should_receive(:include_spec?).with("_some/file_").and_return(true)
      expect(subject.instrument_file?("_some/file_")).to be(false)
    end

    it "returns false if the file should be ignored" do
      expect(subject.instrument_file?("_some/file_")).to be(false)
      expect(subject.instrument_file?("_some/other_file_")).to be(false)
    end

    it "returns true if it's a valid file that should get instrumented" do
      expect(subject.instrument_file?("_some/file_for_instrumenting_")).to be(true)
    end

  end

  describe "#include_spec?" do

    it "returns true if the spec was found" do
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

  describe "#specs" do

    it "converts file names that are in registered asset paths into usable asset urls" do
      Teaspoon.configuration.should_receive(:suites).and_return "default" => proc{ |s| s.matcher = Teaspoon::Engine.root.join("spec/javascripts/support/*.*") }
      expect(subject.send(:specs)).to include("support/support.js")
    end

    it "raises an AssetNotServable exception if the file can't be served by sprockets" do
      Teaspoon.configuration.should_receive(:suites).and_return "default" => proc{ |s| s.matcher = __FILE__ }
      expect{ subject.send(:specs) }.to raise_error(Teaspoon::AssetNotServable, "#{__FILE__} is not within an asset path")
    end

  end

  describe "#asset_from_file" do
    before do
      Rails.application.config.assets.stub(paths: ["/Users/person/workspace/spec/javascripts"])
    end

    it "converts a file name into a usable asset url" do
      file = '/Users/person/workspace/spec/javascripts/support/support.js'
      expect(subject.send(:asset_from_file, file)).to eq('support/support.js')
    end

    context "when the file name has .js.coffee or .coffee extensions" do
      it "returns an asset url with a .js suffix" do
        coffee_file = '/Users/person/workspace/spec/javascripts/support/support.coffee'
        expect(subject.send(:asset_from_file, coffee_file)).to eq('support/support.js')
        jscoffee_file = '/Users/person/workspace/spec/javascripts/support/support.js.coffee'
        expect(subject.send(:asset_from_file, jscoffee_file)).to eq('support/support.js')
      end
    end

    context "when the file name contains regex special characters" do
      it "converts a file name into a usable asset url" do
        regex_file = '/Users/person/.$*?{}/spec/javascripts/support/support.js'
        Rails.application.config.assets.stub(paths: ["/Users/person/.$*?{}/spec/javascripts"])
        expect(subject.send(:asset_from_file, regex_file)).to eq('support/support.js')
      end
    end
  end

  describe "#run_hooks" do
    it "runs blocks added with hook" do
      first_value = nil; second_value = nil

      default_suite_config = proc do |suite|
        suite.hook(:before) { first_value = true }
        suite.hook(:before) { second_value = true }
      end

      Teaspoon.configuration.stub(:suites).and_return "default" => default_suite_config

      suite = Teaspoon::Suite.new({suite: :default})
      suite.run_hooks :before

      expect(first_value).to eql(true)
      expect(second_value).to eql(true)
    end
  end
end
