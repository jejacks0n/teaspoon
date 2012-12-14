require "spec_helper"
require "teabag/runner"
require "teabag/formatters/progress_formatter"
require "teabag/exceptions"

describe Teabag::Runner do

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "its constructor" do

    it "creates a progress formatter if no other formatter is provided" do
      subject.formatters.first.should be_a(Teabag::Formatters::ProgressFormatter)
    end

  end

  describe "#process" do

    it "just outputs logs that it doesn't understand" do
      subject.should_receive(:log).with("_line_")
      subject.should_receive(:output_from).and_return(false)
      subject.process("_line_")
    end

    it "doesn't output logs when suppressed" do
      Teabag.configuration.suppress_log = true
      subject.should_not_receive(:log).with("_line_")
      subject.should_receive(:output_from).and_return(false)
      subject.process("_line_")
      Teabag.configuration.suppress_log = false
    end

    it "handles lines and notifies formatters when it should" do
      formatter = double('formatter')
      subject.formatters = [ formatter ]
      formatter.should_receive(:spec)
      formatter.should_receive(:error)
      formatter.should_receive(:results)
      formatter.should_receive(:exception)
      formatter.should_not_receive(:log)
      subject.process('{"_teabag": true, "type": "spec"}')
      subject.process('{"_teabag": true, "type": "error"}')
      subject.process('{"_teabag": true, "type": "results"}')
      subject.process('{"_teabag": true, "type": "exception"}')
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
      subject.process('{"_teabag": true, "type": "spec"}')
      subject.process('{"_teabag": true, "type": "spec", "status": "passed"}')
      subject.process('{"_teabag": true, "type": "spec", "status": "pending"}')
      subject.process('{"_teabag": true, "type": "error"}')
      subject.process('{"_teabag": true, "type": "exception"}')
      subject.failure_count.should == 3
    end

  end

end
