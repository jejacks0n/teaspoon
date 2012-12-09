require "spec_helper"
require "teabag/formatter"
require "teabag/exceptions"

describe Teabag::Formatter do

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#process" do

    it "just outputs logs that it doesn't understand" do
      subject.should_receive(:log).with("_line_")
      subject.should_receive(:output_from).and_return(false)
      subject.process("_line_")
    end

    it "handles lines when it should" do
      subject.should_receive(:spec)
      subject.should_receive(:error)
      subject.should_receive(:results)
      subject.should_not_receive(:log)
      subject.process('{"_teabag": true, "type": "spec"}')
      subject.process('{"_teabag": true, "type": "error"}')
      subject.process('{"_teabag": true, "type": "results"}')
    end

    it "handles bad json" do
      subject.should_receive(:log).with('{bad: true}')
      subject.process('{bad: true}')
    end

    it "handles json when it's not intended for it" do
      subject.should_receive(:log).with('{"good": true}')
      subject.process('{"good": true}')
    end

  end

  describe "#spec" do

    it "logs a green . on pass" do
      subject.should_receive(:log).with(".", 32)
      subject.spec("status" => "pass")
    end

    it "logs a yellow * on skipped" do
      subject.should_receive(:log).with("*", 33)
      subject.spec("status" => "skipped")
    end

    it "logs a red F on anything else" do
      subject.should_receive(:log).with("F", 31)
      subject.spec("status" => "foo")
    end

  end

  describe "#error" do

    it "logs the error" do
      trace = {"file" => "http://127.0.0.1:31337/assets/path/file.js?foo=true&body=1", "line" => 42, "function" => "notAnAnonFunc"}
      subject.error("msg" => "_message_", "trace" => [trace])
      expect(@log).to eq("\e[31m_message_\n\e[0m\e[36m  # path/file.js?foo=true:42 -- notAnAnonFunc\n\e[0m\n")
    end

  end

  describe "#results" do

    describe "with no failures" do

      it "logs the details" do
        subject.results("elapsed" => 0.31337, "failures" => [], "total" => 666)
        expect(@log).to eq("\n\nFinished in 0.31337 seconds\n\e[32m666 examples, 0 failures\n\e[0m")
      end

    end

    describe "with failures" do

      it "logs the details and raises an exception" do
        failures = {"spec" => "some spec", "description" => "some description", "link" => "?grep=some%20spec"}
        expect {
          subject.results("elapsed" => 0.31337, "failures" => [failures], "total" => 666)
        }.to raise_error(Teabag::Failure)
        expect(@log).to eq("\n\nFailures:\n\n  1) some spec\n\e[31m    Failure/Error: some description\n\e[0m\nFinished in 0.31337 seconds\n\e[31m666 examples, 1 failure\n\e[0m\nFailed examples:\n\e[31m\n/teabag?grep=some%20spec\e[0m\n\n")
      end

    end

  end

  describe "#log" do

    it "calls STDOUT.write" do
      STDOUT.should_receive(:print).with("foo")
      subject.send(:log, "foo")
    end

    it "colorizes" do
      STDOUT.should_receive(:print).with("\e[31mfoo\e[0m")
      subject.send(:log, "foo", 31)
    end
  end

end
