require "spec_helper"
require "teaspoon/runner"
require "teaspoon/exceptions"

describe Teaspoon::Runner do

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "constructor" do

    it "instantiates formatters based on configuration" do
      Teaspoon.configuration.should_receive(:formatters).and_return(["dot", "xml"])
      Teaspoon::Formatters::XmlFormatter = Class.new do
        def initialize(suite_name = :default) end
      end
      expect(subject.formatters[0]).to be_a(Teaspoon::Formatters::DotFormatter)
      expect(subject.formatters[1]).to be_a(Teaspoon::Formatters::XmlFormatter)
    end

  end

  describe "#suppress_logs?" do

    it "returns true if the configuration is true" do
      Teaspoon.configuration.should_receive(:suppress_log).and_return(true)
      expect(subject.suppress_logs?).to be(true)
    end

    it "asks each formatter if it needs to suppress logs" do
      Teaspoon.configuration.should_receive(:suppress_log).and_return(false)
      subject.formatters = [mock(suppress_logs?: true)]
      expect(subject.suppress_logs?).to be(true)
    end

    it "memoizes" do
      Teaspoon.configuration.should_not_receive(:suppress_log)
      subject.instance_variable_set(:@suppress_logs, true)
      expect(subject.suppress_logs?).to be(true)
    end

  end

  describe "#process" do

    before do
      subject.instance_variable_set(:@suppress_logs, false)
    end

    it "just outputs logs that it doesn't understand" do
      subject.should_receive(:log).with("_line_")
      subject.should_receive(:output_from).and_return(false)
      subject.process("_line_")
    end

    it "doesn't output logs when suppressed" do
      subject.should_receive(:suppress_logs?).and_return(true)
      subject.should_not_receive(:log).with("_line_")
      subject.should_receive(:output_from).and_return(false)
      subject.process("_line_")
    end

    it "handles lines and notifies formatters when it should" do
      formatter = double('formatter')
      subject.formatters = [ formatter ]
      formatter.should_receive(:spec)
      formatter.should_receive(:error)
      formatter.should_receive(:results)
      formatter.should_receive(:exception)
      formatter.should_not_receive(:log)
      subject.process('{"_teaspoon": true, "type": "spec"}')
      subject.process('{"_teaspoon": true, "type": "error"}')
      subject.process('{"_teaspoon": true, "type": "results"}')
      subject.process('{"_teaspoon": true, "type": "exception"}')
    end

    it "handles bad json" do
      subject.should_receive(:log).with("{bad: true}")
      subject.process("{bad: true}")
    end

    it "handles json when it's not intended for it" do
      subject.should_receive(:log).with('{"good": true}')
      subject.process('{"good": true}')
    end

    it 'keeps a count of errors' do
      subject.formatters = []
      subject.process('{"_teaspoon": true, "type": "spec"}')
      subject.process('{"_teaspoon": true, "type": "spec", "status": "passed"}')
      subject.process('{"_teaspoon": true, "type": "spec", "status": "pending"}')
      subject.process('{"_teaspoon": true, "type": "error"}')
      subject.process('{"_teaspoon": true, "type": "exception"}')
      subject.process('{"_teaspoon": true, "type": "results"}')
      expect(subject.failure_count).to be(1)
    end

  end

end
