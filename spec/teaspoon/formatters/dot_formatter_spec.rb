require "spec_helper"

describe Teaspoon::Formatters::DotFormatter do

  let(:passing_spec) { double(passing?: true) }
  let(:pending_spec) { double(passing?: false, pending?: true, description: "_description_") }
  let(:failing_spec) { double(passing?: false, pending?: false, description: "_description_", message: "_message_", link: "_link_") }

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#spec" do

    it "logs a green . on passing results" do
      subject.spec(passing_spec)
      expect(@log).to eq("\e[32m.\e[0m")
    end

    it "logs a yellow * on pending results" do
      subject.spec(pending_spec)
      expect(@log).to eq("\e[33m*\e[0m")
    end

    it "logs a red F on failing results" do
      subject.spec(failing_spec)
      expect(@log).to eq("\e[31mF\e[0m")
    end

  end

  describe "#error" do

    let(:result) { double(message: "_message_", trace: [{"file" => "http://127.0.0.1:31337/assets/path/file.js?foo=true&body=1", "line" => 42, "function" => "notAnAnonFunc"}]) }

    it "logs the error" do
      subject.error(result)
      expect(@log).to eq("\e[31m_message_\e[0m\n\e[36m  # path/file.js?foo=true:42 -- notAnAnonFunc\e[0m\n\n")
    end

  end

  describe "#console" do

    it "logs the message" do
      subject.console("_message_\n")
      expect(@log).to eq("_message_\n")
    end

  end

  describe "#result" do

    let(:result) { double(elapsed: 3.1337, coverage: nil) }

    before do
      subject.run_count = 666
    end

    describe "with no failures" do

      it "logs the stats" do
        subject.result(result)
        expect(@log).to eq("\n\nFinished in 3.1337 seconds\n\e[32m666 examples, 0 failures\e[0m\n")
      end

    end

    describe "with failures" do

      before do
        subject.failures << failing_spec
      end

      it "logs the failures" do
        subject.result(result)
        expect(@log).to eq("\n\nFailures:\n\n  1) _description_\n\e[31m     Failure/Error: _message_\n\e[0m\nFinished in 3.1337 seconds\n\e[31m666 examples, 1 failure\e[0m\n\nFailed examples:\n\n\e[31mteaspoon -s default --filter=\"_link_\"\e[0m\n")
      end

    end

    describe "with pending" do

      before do
        subject.pendings << pending_spec
      end

      it "logs the pending specs" do
        subject.result(result)
        expect(@log).to eq("\n\nPending:\n\e[33m  _description_\e[0m\n\e[36m    # Not yet implemented\n\e[0m\nFinished in 3.1337 seconds\n\e[33m666 examples, 0 failures, 1 pending\e[0m\n")
      end

    end

  end

  describe "#coverage" do

    it "logs the coverage" do
      subject.coverage("_text_\n\n_text_summary_")
      expect(@log).to eq("\n_text_\n\n_text_summary_\n")
    end

  end

  describe "#threshold_failure" do

    it "logs the threshold failures" do
      subject.threshold_failure("_was_not_met_\n_was_not_met_")
      expect(@log).to eq("\e[31m\n_was_not_met_\n_was_not_met_\n\e[0m\n")
    end

  end

end
