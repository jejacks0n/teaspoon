# encoding: utf-8

require "spec_helper"
require "rack/test"

describe Teaspoon::Instrumentation do

  subject { Teaspoon::Instrumentation }

  let(:asset) { double('asset', source: nil, pathname: 'path/to/instrument.js') }
  let(:response) { [200, {"Content-Type" => "application/javascript"}, asset] }
  let(:env) { {"QUERY_STRING" => "instrument=true"} }

  before do
    Teaspoon::Instrumentation.stub(:istanbul).and_return("/path/to/istanbul")
    Teaspoon::Instrumentation.instance_variable_set(:@executable, nil)
  end

  after do
    Teaspoon::Instrumentation.instance_variable_set(:@executable, nil)
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

    let(:asset) { double(source: source, pathname: 'path/to/instrument.js') }
    let(:source) { "function add(a, b) { return a + b } // ☃ " }

    before do
      Teaspoon::Instrumentation.stub(:add?).and_return(true)
      asset.should_receive(:clone).and_return(asset)

      File.stub(:open)
      subject.any_instance.stub(:instrument).and_return(source + " // instrumented")

      path = nil
      Dir.mktmpdir { |p| path = p }
      Dir.stub(:mktmpdir).and_yield(path)
      @output = File.join(path, "instrument.js")
    end

    it "writes the file to a tmp path" do
      file = double('file')
      File.should_receive(:open).with(@output, "w").and_yield(file)
      file.should_receive(:write).with("function add(a, b) { return a + b } // ☃ ")
      subject.add_to(response, env)
    end

    it "instruments the javascript file" do
      subject.any_instance.should_receive(:instrument).with(@output).and_return("_instrumented_")
      subject.add_to(response, env)
    end

    it "replaces the response array with the appropriate information" do
      response = [666, {"Content-Type" => "application/javascript"}, asset]
      expected = [666, {"Content-Type" => "application/javascript", "Content-Length" => "59"}, asset]

      subject.add_to(response, env)
      expect(response).to eq(expected)
    end

  end

end
