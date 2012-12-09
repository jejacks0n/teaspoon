require "spec_helper"
require "teabag/console"

describe Teabag::Console do

  let(:server) { mock(start: nil, url: "http://url.com") }

  before do
    subject.instance_variable_set(:@server, server)
    subject.instance_variable_set(:@suites, [:default, :foo])
  end

  describe "#execute" do

    it "starts the server and calls run" do
      subject.should_receive(:start_server)
      subject.should_receive(:run_specs).twice
      subject.execute
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
      @io = mock(each_line: nil)
      IO.stub(:popen).and_return(@io)
      STDOUT.stub(:print)
    end

    it "instantiates the formatter" do
      Teabag::Formatter.should_receive(:new)
      subject.run_specs
    end

    it "uses popen and logs the results of each line using the formatter" do
      arg = %{#{Phantomjs.executable_path} #{Teabag::Engine.root.join("lib/teabag/phantomjs/runner.coffee")} http://url.com/teabag/}

      Teabag::Formatter.any_instance.should_receive(:process).with("_line_")
      @io.should_receive(:each_line) { |&b| @block = b }
      IO.should_receive(:popen).with(arg).and_return(@io)

      subject.run_specs
      @block.call("_line_")
    end

  end

end
