require "spec_helper"
require "teaspoon/runner"
require "teaspoon/exceptions"

describe Teaspoon::Runner do

  before do
    Teaspoon.configuration.stub(:formatters).and_return([])
  end

  describe "#initialize" do

    it "sets @suite_name and @failure_count" do
      subject = Teaspoon::Runner.new(:foo)
      expect(subject.instance_variable_get(:@suite_name)).to eq(:foo)
      expect(subject.failure_count).to eq(0)
    end

    it "instantiates formatters based on configuration" do
      Teaspoon.configuration.stub(:formatters).and_return(["dot", "xml"])
      Teaspoon::Formatters::XmlFormatter = Class.new do
        def initialize(suite_name = :default) end
      end
      expect(subject.instance_variable_get(:@formatters)[0]).to be_a(Teaspoon::Formatters::DotFormatter)
      expect(subject.instance_variable_get(:@formatters)[1]).to be_a(Teaspoon::Formatters::XmlFormatter)
    end

  end

  describe "#process" do

    let(:formatter) { double }

    before do
      subject.instance_variable_set(:@formatters, [formatter])
    end

    it "notifies formatters when it understands the log" do
      formatter.should_receive(:foo)
      formatter.should_not_receive(:bar)
      subject.process('{"_teaspoon":true,"type":"foo"}')
      subject.process('{"_teaspoon":false,"type":"bar"}')
    end

    it "notifies formatters of console output when it doesn't understand the log" do
      formatter.should_receive(:console).with("_line_")
      subject.should_receive(:result_from_line).and_return(false)
      subject.process("_line_")
    end

    it "handles bad json" do
      formatter.should_receive(:console).with("{bad: true}")
      subject.process("{bad: true}")
    end

    it "handles json when it's not intended for it" do
      formatter.should_receive(:console).with('{"good": true}')
      subject.process('{"good": true}')
    end

    it "keeps a count of errors" do
      subject.process('{"_teaspoon":true,"type":"spec"}')
      subject.process('{"_teaspoon":true,"type":"spec", "status": "passed"}')
      subject.process('{"_teaspoon":true,"type":"spec", "status": "pending"}')
      subject.process('{"_teaspoon":true,"type":"error"}')
      subject.process('{"_teaspoon":true,"type":"results"}')
      expect(subject.failure_count).to be(1)
    end

  end

end
