require "spec_helper"

describe Teaspoon::Formatters::JunitFormatter do

  let(:passing_spec) { double(passing?: true, suite: "_suite_name_", label: "_passing_label_") }
  let(:pending_spec) { double(passing?: false, pending?: true, suite: "_suite_name_", label: "_pending_label_") }
  let(:failing_spec) { double(passing?: false, pending?: false, suite: "_suite_name_", label: "_failing&label_", message: "_failure_message_") }

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#runner" do

    let(:result) { double(start: "_start_", total: 42) }

    before do
      subject.instance_variable_set(:@suite_name, "not_default")
    end

    it "starts the suite" do
      subject.runner(result)
      expect(@log).to eq(%Q{<?xml version="1.0" encoding="UTF-8"?>\n<testsuites name="Teaspoon">\n<testsuite name="not_default" tests="42" time="_start_">\n})
    end

  end

  describe "#suite" do

    let(:result) { double(label: "_label_") }

    it "calls #log_end_suite" do
      subject.should_receive(:log_end_suite)
      subject.suite(result)
    end

    it "logs the start of the testsuite" do
      subject.suite(result)
      expect(@log).to eq(%Q{<testsuite name="_label_">\n})
    end

  end

  describe "#spec" do

    it "logs a passing testcase on passing results" do
      subject.spec(passing_spec)
      expect(@log).to eq(%Q{<testcase classname="_suite_name_" name="_passing_label_">\n</testcase>\n})
    end

    it "logs a skipped testcase on pending results" do
      subject.spec(pending_spec)
      expect(@log).to eq(%Q{<testcase classname="_suite_name_" name="_pending_label_">\n  <skipped/>\n</testcase>\n})
    end

    it "logs a failing testcase with the message on failing results" do
      subject.spec(failing_spec)
      expect(@log).to include(%Q{<testcase classname="_suite_name_" name="_failing&amp;label_">\n})
      expect(@log).to include(%Q{  <failure type="AssertionFailed">\n<![CDATA[\n_failure_message_\n]]>\n</failure>\n})
      expect(@log).to include(%Q{</testcase>\n})
    end

    it "includes any stdout" do
      subject.instance_variable_set(:@stdout, "_stdout_")
      subject.spec(passing_spec)
      expect(@log).to eq(%Q{<testcase classname="_suite_name_" name="_passing_label_">\n<system-out>\n<![CDATA[\n_stdout_\n]]>\n</system-out>\n</testcase>\n})
    end

  end

  describe "#result" do

    let(:result) { double(coverage: nil) }

    it "closes the last suite" do
      subject.should_receive(:log_end_suite)
      subject.result(result)
    end

  end

  describe "#coverage" do

    it "logs the coverage" do
      subject.coverage("_text_\n\n_text_summary_")
      expect(@log).to eq(%Q{<testsuite name="Coverage summary" tests="0">\n<properties>\n<![CDATA[\n_text_\n_text_summary_\n]]>\n<properties>\n</testsuite>\n})
    end

  end

  describe "#threshold_failure" do

    it "logs the threshold failures" do
      subject.threshold_failure("_was_not_met_\n_was_not_met_")
      expect(@log).to include(%Q{<testsuite name="Coverage thresholds" tests="1">\n})
      expect(@log).to include(%Q{<testcase classname="Coverage thresholds" name="were not met">\n})
      expect(@log).to include(%Q{  <failure type="AssertionFailed">\n<![CDATA[\n_was_not_met_\n_was_not_met_\n]]>\n</failure>\n})
      expect(@log).to include(%Q{</testcase>\n})
      expect(@log).to include(%Q{</testsuite>\n})
    end

  end

  describe "#complete" do

    it "logs the closing suite tags" do
      subject.complete(2)
      expect(@log).to include(%Q{</testsuite>\n</testsuites>})
    end

  end

end
