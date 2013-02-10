require "spec_helper"
require "rack/test"

describe Teabag::Instrumentation do

  subject { Teabag::Instrumentation }

  before do
    Teabag::Instrumentation.stub(:which).and_return("/path/to/istanbul")
    Teabag::Instrumentation.instance_variable_set(:@executable, nil)
  end

  after do
    Teabag::Instrumentation.instance_variable_set(:@executable, nil)
  end

  describe ".env" do

    it "allows getting/setting the env" do
      env = {foo: "bar"}
      subject.env = env
      expect(subject.env).to be(env)
    end

  end

  describe ".add?" do

    it "reads the query string to determine if it should add instrumentation" do
      subject.stub(:executable).and_return(true)
      subject.env = {"QUERY_STRING" => "instrument=true"}
      expect(subject.add?).to be(true)
      subject.env = {"QUERY_STRING" => "instrument=false"}
      expect(subject.add?).to be(false)
      subject.env = {"QUERY_STRING" => "instrument=1"}
      expect(subject.add?).to be(true)
      subject.env = {"QUERY_STRING" => "instrument=0"}
      expect(subject.add?).to be(false)
    end

    it "checks if there's an executable" do
      subject.env = {"QUERY_STRING" => "instrument=true"}
      subject.should_receive(:executable).and_return("/path/to/istanbul")
      expect(subject.add?).to be(true)
      subject.should_receive(:executable).and_return(nil)
      expect(subject.add?).to be(false)
    end

  end

  describe ".executable" do

    it "returns the executable" do
      expect(subject.executable).to eq("/path/to/istanbul")
      expect(subject.instance_variable_get(:@executable)).to eq("/path/to/istanbul")
    end

  end

  describe "#evaluate" do

    subject { Teabag::Instrumentation.new(Rails.root.join("app/assets/javascripts/instrumented1.coffee").to_s) }

    before do
      Teabag::Instrumentation.stub(:add?).and_return(true)
      subject.stub(:instrument).and_return("_foo_")
      File.stub(:write)

      path = nil
      Dir.mktmpdir { |p| path = p }
      Dir.stub(:mktmpdir).and_yield(path)
      @output = File.join(path, "instrumented1.coffee")
    end

    it "writes the file to a tmp path" do
      File.should_receive(:write).with(@output, "instrumented1 = -> 'foo'\n")
      expect(subject.evaluate({}, {})).to eq("_foo_")
    end

    it "instruments a javascript file" do
      subject.should_receive(:instrument).with(@output).and_return("_instrumented_")
      expect(subject.evaluate({}, {})).to eq("_instrumented_")
    end

  end

end
