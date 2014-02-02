require "spec_helper"

describe Teaspoon::Formatters::Base do

  let(:passing_spec) { double(passing?: true) }
  let(:pending_spec) { double(passing?: false, pending?: true) }
  let(:failing_spec) { double(passing?: false, pending?: false) }

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#initialize" do

    subject { Teaspoon::Formatters::Base.new(:foo) }

    it "assigns various instance vars" do
      expect(subject.instance_variable_get(:@suite_name)).to eq("foo")
      expect(subject.instance_variable_get(:@stdout)).to eq("")
      expect(subject.instance_variable_get(:@suite)).to eq(nil)
      expect(subject.instance_variable_get(:@last_suite)).to eq(nil)
    end

    it "assigns @total_count, @run_count, and arrays for tracking results" do
      expect(subject.total_count).to eq(0)
      expect(subject.run_count).to eq(0)
      expect(subject.passes).to eq([])
      expect(subject.pendings).to eq([])
      expect(subject.failures).to eq([])
      expect(subject.errors).to eq([])
    end

  end

  describe "#runner" do

    let(:result) { double(total: 666) }

    it "sets @total_count" do
      subject.runner(result)
      expect(subject.total_count).to eq(666)
    end

    it "calls #log_runner" do
      subject.should_receive(:log_runner).with(result)
      subject.runner(result)
    end

    it "doesn't call #log_runner if log is false" do
      subject.should_not_receive(:log_runner)
      subject.runner(result, false)
    end

  end

  describe "#suite" do

    let(:result) { double }

    it "sets @suite, and @last_suite to the result" do
      subject.suite(result)
      expect(subject.instance_variable_get(:@suite)).to eq(result)
      expect(subject.instance_variable_get(:@last_suite)).to eq(result)
    end

    it "calls #log_suite" do
      subject.should_receive(:log_suite).with(result)
      subject.suite(result)
    end

    it "doesn't call #log_suite if log is false" do
      subject.should_not_receive(:log_suite)
      subject.suite(result, false)
    end

  end

  describe "#spec" do

    it "increments the run count" do
      subject.spec(failing_spec)
      expect(subject.run_count).to eq(1)
      subject.spec(failing_spec)
      expect(subject.run_count).to eq(2)
    end

    it "adds to the correct array on passing results" do
      subject.spec(passing_spec)
      expect(subject.run_count).to eq(1)
      expect(subject.passes).to eq([passing_spec])
    end

    it "adds to the correct array on pending results" do
      subject.spec(pending_spec)
      expect(subject.run_count).to eq(1)
      expect(subject.pendings).to eq([pending_spec])
    end

    it "adds to the correct array on failing results" do
      subject.spec(failing_spec)
      expect(subject.run_count).to eq(1)
      expect(subject.failures).to eq([failing_spec])
    end

    it "calls #log_spec" do
      subject.should_receive(:log_spec).with(failing_spec)
      subject.spec(failing_spec)
    end

    it "doesn't call #log_spec if log is false" do
      subject.should_not_receive(:log_spec)
      subject.spec(failing_spec, false)
    end

    it "clears @stdout" do
      subject.instance_variable_set(:@stdout, "----")
      subject.spec(failing_spec)
      expect(subject.instance_variable_get(:@stdout)).to eq("")
    end

  end

  describe "#error" do

    let(:result) { double }

    it "tracks the error" do
      subject.error(result)
      expect(subject.errors).to eq([result])
    end

    it "calls #log_error" do
      subject.should_receive(:log_error).with(result)
      subject.error(result)
    end

    it "doesn't call #log_error if log is false" do
      subject.should_not_receive(:log_error)
      subject.error(result, false)
    end

  end

  describe "#exception" do

    let(:result) { double(message: "_message_") }

    it "calls #log_exception when appropriate and raises a Teaspoon::RunnerException" do
      subject.should_receive(:log_exception).with(result)
      expect { subject.exception(result) }.to raise_error Teaspoon::RunnerException

      subject.should_not_receive(:log_exception)
      expect { subject.exception(result, false) }.to raise_error Teaspoon::RunnerException
    end

  end

  describe "#console" do

    it "adds the string to @stdout" do
      subject.console("_message1_")
      subject.console("_message2_")
      expect(subject.instance_variable_get(:@stdout)).to eq("_message1__message2_")
    end

    it "calls #log_console" do
      subject.should_receive(:log_console).with("_message_")
      subject.console("_message_")
    end

    it "doesn't call #log_console if log is false" do
      subject.should_not_receive(:log_console)
      subject.console("_message_", false)
    end

  end

  describe "#result" do

    let(:result) { double(coverage: nil) }
    let(:result_with_coverage) { double(coverage: "_coverage_") }

    it "calls #log_result" do
      subject.should_receive(:log_result).with(result)
      subject.result(result)
    end

    it "calls #log_coverage" do
      subject.should_receive(:log_coverage).with("_coverage_")
      subject.result(result_with_coverage)
    end

    it "raises a Teaspoon::Failure exception if failures and configured to fail fast" do
      Teaspoon.configuration.should_receive(:fail_fast).and_return(true)
      subject.failures = ['failure']
      subject.should_receive(:log_line)
      expect { subject.result(result) }.to raise_error Teaspoon::Failure
    end

  end

  describe "#log_spec" do

    it "calls #log_passing_spec on passing results" do
      subject.should_receive(:log_passing_spec).with(passing_spec)
      subject.send(:log_spec, passing_spec)
    end

    it "calls #log_pending_spec on pending results" do
      subject.should_receive(:log_pending_spec).with(pending_spec)
      subject.send(:log_spec, pending_spec)
    end

    it "calls #log_failing_spec on failing results" do
      subject.should_receive(:log_failing_spec).with(failing_spec)
      subject.send(:log_spec, failing_spec)
    end

  end

  describe "#log_coverage" do

    let(:data) { double(reports: nil) }

    it "logs the coverage information" do
      Teaspoon::Coverage.should_receive(:new).with("_data_", "default").and_return(data)
      data.should_receive(:reports).and_return("_reports_")
      STDOUT.should_receive(:print).with("_reports_")
      subject.send(:log_coverage, "_data_")
    end

    it "doesn't log if there's no data" do
      Teaspoon::Coverage.should_not_receive(:new)
      subject.send(:log_coverage, {})
    end

    it "doesn't log when suppressing logs" do
      Teaspoon.configuration.should_receive(:suppress_log).and_return(true)
      Teaspoon::Coverage.should_receive(:new).and_return(data)
      STDOUT.should_not_receive(:print)
      subject.send(:log_coverage, "_data_")
    end

  end

end
