require "spec_helper"
require "teaspoon/runner"
require "teaspoon/exceptions"
require "teaspoon/coverage"

describe Teaspoon::Runner do
  before do
    allow(Teaspoon.configuration).to receive(:formatters).and_return([])
  end

  describe "#initialize" do
    it "sets @suite_name and @failure_count" do
      subject = Teaspoon::Runner.new(:foo)
      expect(subject.instance_variable_get(:@suite_name)).to eq(:foo)
      expect(subject.failure_count).to eq(0)
    end

    it "instantiates formatters based on configuration" do
      allow(Teaspoon.configuration).to receive(:formatters).and_return(["dot", "pride"])

      expect(subject.instance_variable_get(:@formatters)[0]).to be_a(Teaspoon::Formatter::Dot)
      expect(subject.instance_variable_get(:@formatters)[1]).to be_a(Teaspoon::Formatter::Pride)
    end
  end

  describe "#process" do
    let(:formatter) { double }
    let(:coverage) { double(generate_reports: nil, check_thresholds: nil) }

    before do
      subject.instance_variable_set(:@formatters, [formatter])
    end

    it "notifies formatters when it understands the log" do
      expect(formatter).to receive(:foo)
      expect(formatter).to_not receive(:bar)
      subject.process('{"_teaspoon":true,"type":"foo"}')
      subject.process('{"_teaspoon":false,"type":"bar"}')
    end

    it "notifies formatters of console output when it doesn't understand the log" do
      expect(formatter).to receive(:console).with("_line_")
      expect(subject).to receive(:result_from_line).and_return(false)
      subject.process("_line_")
    end

    it "handles bad json" do
      expect(formatter).to receive(:console).with("{bad: true}")
      subject.process("{bad: true}")
    end

    it "handles json when it's not intended for it" do
      expect(formatter).to receive(:console).with('{"good": true}')
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
      it "notifies itself, and raises an exception" do
        expect(subject).to receive(:on_exception).and_call_original
        expect { subject.process('{"_teaspoon":true,"type":"exception","message":"_message_"}') }.to raise_error(
          Teaspoon::RunnerError,
          "_message_"
        )
      end
    end

    describe "with a result" do
      before do
        allow(Teaspoon::Coverage).to receive(:new).and_return(coverage)
      end

      it "notifies itself" do
        expect(subject).to receive(:on_result)
        subject.process('{"_teaspoon":true,"type":"result"}')
      end

      it "resolves coverage" do
        expect(Teaspoon.configuration).to receive(:use_coverage).and_return("_config_")
        expect(Teaspoon::Coverage).to receive(:new).with(:default, "_coverage_").and_return(coverage)
        expect(coverage).to receive(:generate_reports).and_yield("_generated_reports_")
        expect(coverage).to receive(:check_thresholds).and_yield("_threshold_failures_")
        expect(subject).to receive(:notify_formatters).once.with("coverage", "_generated_reports_")
        expect(subject).to receive(:notify_formatters).once.with("threshold_failure", "_threshold_failures_")
        expect(subject).to receive(:notify_formatters).exactly(2).times.and_call_original
        subject.process('{"_teaspoon":true,"type":"result","coverage":"_coverage_"}')
        expect(subject.failure_count).to eq(1)
      end

      it "raises an exception when istanbul cannot be found if coverage is requested" do
        expect(Teaspoon.configuration).to receive(:use_coverage).and_return("_config_")
        expect(Teaspoon::Instrumentation).to receive(:executable).and_return(nil)

        expect { subject.process('{"_teaspoon":true,"type":"result","coverage":"_coverage_"}') }.to raise_error(Teaspoon::IstanbulNotFoundError)
      end
    end
  end
end
