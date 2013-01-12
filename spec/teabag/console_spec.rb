require "spec_helper"
require "teabag/console"

describe Teabag::Console do

  let(:server) { mock(start: nil, url: "http://url.com") }

  before do
    subject.instance_variable_set(:@server, server)
    subject.instance_variable_set(:@suites, [:default, :foo])
    Teabag::Environment.stub(:load)
  end

  describe "#initialize" do

    it "loads the environment" do
      Teabag::Environment.should_receive(:load).once
      Teabag::Console.new()
    end

    it "assigns @options" do
      options = {foo: "bar"}
      instance = Teabag::Console.new(options)
      expect(instance.instance_variable_get(:@options)).to eql(options)
    end

    it "assigns @files" do
      files = ["file1"]
      instance = Teabag::Console.new(nil, files)
      expect(instance.instance_variable_get(:@files)).to eql(files)
    end

    it "assigns @suites" do
      instance = Teabag::Console.new({suite: "foo"})
      expect(instance.instance_variable_get(:@suites)).to eql(["foo"])
      instance = Teabag::Console.new()
      expect(instance.instance_variable_get(:@suites)).to eql(Teabag.configuration.suites.keys)
    end

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

    it "calls run_specs on the driver" do
      driver = mock(run_specs: nil)
      subject.should_receive(:driver).and_return(driver)
      driver.should_receive(:run_specs).with(:suite_name, "http://url.com/teabag/suite_name")
      subject.run_specs(:suite_name)
    end

  end

end
