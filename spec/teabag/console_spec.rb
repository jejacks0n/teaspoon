require "spec_helper"
require "teabag/console"

describe Teabag::Console do

  let(:server) { mock(start: nil, url: "http://url.com") }

  before do
    subject.instance_variable_set(:@server, server)
    subject.instance_variable_set(:@suites, [:default, :foo])
  end

  describe "#execute" do

    before do
      STDOUT.stub(:print)
    end

    it "starts the server and calls run" do
      STDOUT.should_receive(:print).with("Starting server...\n")
      subject.should_receive(:start_server)
      STDOUT.should_receive(:print).with("Teabag running default suite at http://url.com/teabag/default...\n")
      STDOUT.should_receive(:print).with("Teabag running foo suite at http://url.com/teabag/foo...\n")
      subject.should_receive(:run_specs).twice.and_return(2)
      result = subject.execute
      expect(result).to be(true)
    end

    it "starts the server and calls run" do
      subject.should_receive(:start_server)
      subject.should_receive(:run_specs).twice.and_return(0)
      result = subject.execute
      expect(result).to be(false)
    end

  end

  describe "#start_server" do

    it "starts the server" do
      Teabag::Server.should_receive(:new).and_return(server)
      server.should_receive(:start)
      subject.start_server
    end

  end

  describe "#run_specs" do

    before do
      Phantomjs.stub(:run)
    end

    it "instantiates the formatter" do
      formatter = mock(failure_count: nil)
      Teabag::Runner.should_receive(:new).and_return(formatter)
      subject.run_specs(:default)
    end

    it "phantomjs.run and logs the results of each line using the formatter" do
      args = [Teabag::Engine.root.join("lib/teabag/phantomjs/runner.coffee").to_s, "http://url.com/teabag/default"]
      Teabag::Runner.any_instance.should_receive(:process).with("_line_")
      @block = nil
      Phantomjs.should_receive(:run).with(*args) { |&b| @block = b }
      subject.run_specs(:default)
      @block.call("_line_")
    end

  end

end
