require "spec_helper"

describe Teaspoon::Formatters::Base do

  let(:passing_spec) { double(passing?: true) }
  let(:pending_spec) { double(passing?: false, pending?: true) }
  let(:failing_spec) { double(passing?: false, pending?: false) }
  let(:result) { double }

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#initialize" do

    subject { Teaspoon::Formatters::Base.new(:foo, "_output_file_") }

    before do
      File.stub(:open)
    end

    it "assigns various instance vars" do
      expect(subject.instance_variable_get(:@suite_name)).to eq("foo")
      expect(subject.instance_variable_get(:@output_file)).to eq("_output_file_")
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

    it "writes a new output file if one is specified" do
      File.should_receive(:open).with("_output_file_", "w")
      subject
    end

  end

  describe "#runner" do

    let(:result) { double(total: 666) }

    it "sets @total_count" do
      subject.runner(result)
      expect(subject.total_count).to eq(666)
    end

    it "calls #log_runner when appropriate" do
      subject.should_receive(:log_runner).with(result)
      subject.runner(result)

      subject.should_not_receive(:log_runner)
      subject.runner(result, false)
    end

  end

  describe "#suite" do

    it "sets @suite, and @last_suite to the result" do
      subject.suite(result)
      expect(subject.instance_variable_get(:@suite)).to eq(result)
      expect(subject.instance_variable_get(:@last_suite)).to eq(result)
    end

    it "calls #log_suite when appropriate" do
      subject.should_receive(:log_suite).with(result)
      subject.suite(result)

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

    it "calls #log_spec when appropriate" do
      subject.should_receive(:log_spec).with(failing_spec)
      subject.spec(failing_spec)

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

    it "tracks the error" do
      subject.error(result)
      expect(subject.errors).to eq([result])
    end

    it "calls #log_error when appropriate" do
      subject.should_receive(:log_error).with(result)
      subject.error(result)

      subject.should_not_receive(:log_error)
      subject.error(result, false)
    end

  end

  describe "#exception" do

    it "calls #log_exception when appropriate" do
      subject.should_receive(:log_exception).with(result)
      subject.exception(result)

      subject.should_not_receive(:log_exception)
      subject.exception(result, false)
    end

  end

  describe "#console" do

    it "adds the string to @stdout" do
      subject.console("_message1_")
      subject.console("_message2_")
      expect(subject.instance_variable_get(:@stdout)).to eq("_message1__message2_")
    end

    it "calls #log_console when appropriate" do
      subject.should_receive(:log_console).with("_message_")
      subject.console("_message_")

      subject.should_not_receive(:log_console)
      subject.console("_message_", false)
    end

  end

  describe "#result" do

    let(:result) { double(coverage: nil) }

    it "calls #log_result when appropriate" do
      subject.should_receive(:log_result).with(result)
      subject.result(result)

      subject.should_not_receive(:log_result)
      subject.result(result, false)
    end

  end

  describe "#coverage" do

    it "calls #log_coverage when appropriate" do
      subject.should_receive(:log_coverage).with("_message_")
      subject.coverage("_message_")

      subject.should_receive(:log_coverage).with("_message_")
      subject.coverage("_message_")
    end

  end

  describe "#threshold_failure" do

    it "calls #log_threshold_failure when appropriate" do
      subject.should_receive(:log_threshold_failure).with("_message_")
      subject.threshold_failure("_message_")

      subject.should_receive(:log_threshold_failure).with("_message_")
      subject.threshold_failure("_message_")
    end

  end

  describe "#complete" do

    it "calls #log_complete when appropriate" do
      subject.should_receive(:log_complete).with(42)
      subject.complete(42)

      subject.should_receive(:log_complete).with(0)
      subject.complete(0)
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

  describe "logging to file" do

    it "logs to a file" do
      handle = double(write: nil)
      File.should_receive(:open).with("_output_file_", "a").and_yield(handle)
      handle.should_receive(:write).with("_str_")
      subject.send(:log_to_file, "_str_", "_output_file_")
    end

    it "raises a Teaspoon::FileNotWritable exception if the file can't be written to" do
      File.should_receive(:open).and_raise(IOError, "_io_error_message_")
      expect { subject.send(:log_to_file, "_str_", "_output_file_") }.to raise_error(Teaspoon::FileNotWritable, "_io_error_message_")
    end

  end

end
