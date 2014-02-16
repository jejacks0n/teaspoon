require "spec_helper"

describe Teaspoon::Formatters::TapFormatter do

  let(:passing_spec) { double(passing?: true, description: "_passing_desc_") }
  let(:pending_spec) { double(passing?: false, pending?: true, description: "_pending_desc_") }
  let(:failing_spec) { double(passing?: false, pending?: false, description: "_failing_desc_", message: "_failure_message_") }

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#runner" do

    let(:result) { double(total: 42) }

    it "logs the total count" do
      subject.runner(result)
      expect(@log).to eq("1..42\n")
    end

  end

  describe "#spec" do

    it "logs an ok on passing results" do
      subject.spec(passing_spec)
      expect(@log).to eq("ok 1 - _passing_desc_\n")
    end

    it "logs an ok but [pending] on pending results" do
      subject.spec(pending_spec)
      expect(@log).to eq("ok 1 - [pending] _pending_desc_\n")
    end

    it "logs a not ok on failing results" do
      subject.spec(failing_spec)
      expect(@log).to eq("not ok 1 - _failing_desc_\n  FAIL _failure_message_\n")
    end

  end

  describe "#console" do

    it "logs the message" do
      subject.console("_message1_")
      subject.console("_message2_\n")
      expect(@log).to eq("# _message1_\n# _message2_\n")
    end

  end

  describe "#coverage" do

    it "logs the coverage" do
      subject.coverage("_text_\n\n_text_summary_")
      expect(@log).to eq("# _text_\n# \n# _text_summary_\n")
    end

  end

  describe "#threshold_failure" do

    it "logs the threshold failures" do
      subject.threshold_failure("_was_not_met_\n_was_not_met_")
      expect(@log).to eq("not ok 1 - Coverage threshold failed\n# _was_not_met_\n# _was_not_met_\n")
    end

  end

end
