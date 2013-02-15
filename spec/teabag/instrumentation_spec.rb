require "spec_helper"
require "rack/test"

describe Teabag::Instrumentation do

  subject { Teabag::Instrumentation }

  let(:asset) { mock(source: nil) }
  let(:response) { [200, {"Content-Type" => "application/javascript"}, asset] }
  let(:env) { {"QUERY_STRING" => "instrument=true"} }

  before do
    Teabag::Instrumentation.stub(:which).and_return("/path/to/istanbul")
    Teabag::Instrumentation.instance_variable_set(:@executable, nil)
  end

  after do
    Teabag::Instrumentation.instance_variable_set(:@executable, nil)
  end

  describe ".executable" do

    it "returns the executable" do
      expect(subject.executable).to eq("/path/to/istanbul")
      expect(subject.instance_variable_get(:@executable)).to eq("/path/to/istanbul")
    end

  end

  describe ".add?" do

    before do
      subject.stub(:executable).and_return("/path/to/istanbul")
    end

    it "returns true when everything is good" do
      expect(subject.add?(response, {"QUERY_STRING" => "instrument=true"})).to be(true)
      expect(subject.add?(response, {"QUERY_STRING" => "instrument=1"})).to be(true)
    end

    it "doesn't if the query param isn't set (or isn't something we care about)" do
      expect(subject.add?(response, {})).to_not be(true)
      expect(subject.add?(response, {"QUERY_STRING" => "instrument=foo"})).to_not be(true)
    end

    it "doesn't if response isn't 200" do
      expect(subject.add?([404, {"Content-Type" => "application/javascript"}, asset], env)).to_not be(true)
    end

    it "doesn't when the content type isn't application/javascript" do
      expect(subject.add?([200, {"Content-Type" => "foo/bar"}, asset], env)).to_not be(true)
    end

    it "doesn't if there's no executable" do
      subject.should_receive(:executable).and_return(false)
      expect(subject.add?(response, env)).to_not be(true)
    end

    it "doesn't if there's no asset" do
      expect(subject.add?([404, {"Content-Type" => "application/javascript"}, []], env)).to_not be(true)
    end

  end

  describe ".add_to" do

    let(:asset) { mock(source: "function add(a, b) { return a + b }", pathname: 'path/to/instrument.js') }

    before do
      Teabag::Instrumentation.stub(:add?).and_return(true)

      File.stub(:write)
      subject.stub(:instrument).and_return("_foo_")

      path = nil
      Dir.mktmpdir { |p| path = p }
      Dir.stub(:mktmpdir).and_yield(path)
      @output = File.join(path, "instrument.js")
    end

    it "writes the file to a tmp path" do
      File.should_receive(:write).with(@output, "function add(a, b) { return a + b }")
      subject.add_to(response, env)
    end

    it "instruments the javascript file" do
      subject.should_receive(:instrument).with(@output).and_return("_instrumented_")
      subject.add_to(response, env)
    end

    it "replaces the response array with the appropriate information" do
      response = [666, {"Content-Type" => "application/javascript"}, asset]
      expected = [666, {"Content-Type" => "application/javascript", "Content-Length" => "5"}, asset]

      subject.add_to(response, env)
      expect(response).to eq(expected)
    end

  end

end
