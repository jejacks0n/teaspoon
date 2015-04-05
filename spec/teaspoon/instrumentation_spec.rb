# encoding: utf-8

require "spec_helper"
require "rack/test"

describe Teaspoon::Instrumentation do

  subject { Teaspoon::Instrumentation }

  let(:asset) { double(source: source, pathname: "path/to/instrument.js") }
  let(:source) { "function add(a, b) { return a + b } // ☃ " }
  let(:response) { [200, { "Content-Type" => "application/javascript" }, asset] }
  let(:env) { { "QUERY_STRING" => "instrument=true" } }

  describe ".add_to" do

    before do
      allow(Teaspoon::Instrumentation).to receive(:executable).and_return("/path/to/istanbul")
    end

    before do
      allow(Teaspoon::Instrumentation).to receive(:add?).and_return(true)
      expect(asset).to receive(:clone).and_return(asset)

      allow(File).to receive(:open)
      allow_any_instance_of(subject).to receive(:instrument).and_return(source + " // instrumented")

      path = nil
      Dir.mktmpdir { |p| path = p }
      allow(Dir).to receive(:mktmpdir).and_yield(path)
      @output = File.join(path, "instrument.js")
    end

    it "writes the file to a tmp path" do
      file = double("file")
      expect(File).to receive(:open).with(@output, "w").and_yield(file)
      expect(file).to receive(:write).with("function add(a, b) { return a + b } // ☃ ")
      subject.add_to(response, env)
    end

    it "instruments the javascript file" do
      expect_any_instance_of(subject).to receive(:instrument).with(@output).and_return("_instrumented_")
      subject.add_to(response, env)
    end

    it "replaces the response array with the appropriate information" do
      response = [666, { "Content-Type" => "application/javascript" }, asset]
      expected = [666, { "Content-Type" => "application/javascript", "Content-Length" => "59" }, asset]

      expect(subject.add_to(response, env)).to eq(expected)
    end

    it "raises an exception if istanbul fails" do
      `(exit 1)`
      allow_any_instance_of(subject).to receive(:`)
      allow_any_instance_of(subject).to receive(:instrument).and_call_original
      expect { subject.add_to(response, env) }.to raise_error(
        Teaspoon::DependencyFailure, "Could not generate instrumentation for instrument.js."
      )
    end

  end

  describe ".add?" do

    before do
      allow(Teaspoon::Instrumentation).to receive(:executable).and_return("/path/to/istanbul")
    end

    it "returns true when everything is good" do
      expect(subject.add?(response, "QUERY_STRING" => "instrument=true")).to be(true)
      expect(subject.add?(response, "QUERY_STRING" => "instrument=1")).to be(true)
    end

    it "doesn't if the query param isn't set (or isn't something we care about)" do
      expect(subject.add?(response, {})).to_not be(true)
      expect(subject.add?(response, "QUERY_STRING" => "instrument=foo")).to_not be(true)
    end

    it "doesn't if response isn't 200" do
      expect(subject.add?([404, { "Content-Type" => "application/javascript" }, asset], env)).to_not be(true)
    end

    it "doesn't when the content type isn't application/javascript" do
      expect(subject.add?([200, { "Content-Type" => "foo/bar" }, asset], env)).to_not be(true)
    end

    it "doesn't if there's no executable" do
      expect(subject).to receive(:executable).and_return(false)
      expect(subject.add?(response, env)).to_not be(true)
    end

    it "doesn't if there's no asset" do
      expect(subject.add?([404, { "Content-Type" => "application/javascript" }, []], env)).to_not be(true)
    end

  end

  describe "integration" do

    let(:asset) { Rails.application.assets.find_asset("support/instrumented.coffee") }

    it "instruments a file" do
      pending("needs istanbul to be installed") unless Teaspoon::Instrumentation.executable
      status, headers, asset = subject.add_to(response, "QUERY_STRING" => "instrument=true")
      expect(status).to eq(200)
      expect(headers).to include("Content-Type" => "application/javascript")
      expect(asset.source).to match(/var __cov_.+ = \(Function\('return this'\)\)\(\);/)
    end

  end

end
