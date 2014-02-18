require "spec_helper"
require "teaspoon/runner"
require "teaspoon/exceptions"
require "teaspoon/coverage"

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
        def initialize(_suite_name = :default, _output_file = nil) end
      end
      expect(subject.instance_variable_get(:@formatters)[0]).to be_a(Teaspoon::Formatters::DotFormatter)
      expect(subject.instance_variable_get(:@formatters)[1]).to be_a(Teaspoon::Formatters::XmlFormatter)
    end

    it "raises a Teaspoon::UnknownFormatter exception when a formatter isn't found" do
      Teaspoon.configuration.stub(:formatters).and_return(["bar"])
      expect { Teaspoon::Runner.new(:foo) }.to raise_error Teaspoon::UnknownFormatter, "Unknown formatter: \"bar\""
    end

  end

  describe "#process" do

    let(:formatter) { double }
    let(:coverage) { double(generate_reports: nil, check_thresholds: nil) }

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

    describe "with an exception" do

      it "notifies itself, and raises Teaspoon::RunnerException" do
        subject.should_receive(:on_exception).and_call_original
        expect { subject.process('{"_teaspoon":true,"type":"exception","message":"_message_"}') }.to raise_error Teaspoon::RunnerException, "_message_"
      end

    end

    describe "with a result" do

      before do
        Teaspoon::Coverage.stub(:new).and_return(coverage)
      end

      it "notifies itself" do
        subject.should_receive(:on_result)
        subject.process('{"_teaspoon":true,"type":"result"}')
      end

      it "resolves coverage" do
        Teaspoon.configuration.should_receive(:use_coverage).twice.and_return("_coverage_config_")
        Teaspoon::Coverage.should_receive(:new).with(:default, "_coverage_config_", "_coverage_").and_return(coverage)
        coverage.should_receive(:generate_reports).and_yield("_generated_reports_")
        coverage.should_receive(:check_thresholds).and_yield("_threshold_failures_")
        subject.should_receive(:notify_formatters).once.with("coverage", "_generated_reports_")
        subject.should_receive(:notify_formatters).once.with("threshold_failure", "_threshold_failures_")
        subject.should_receive(:notify_formatters).exactly(2).times.and_call_original
        subject.process('{"_teaspoon":true,"type":"result","coverage":"_coverage_"}')
        expect(subject.failure_count).to eq(1)
      end

    end

  end

end
