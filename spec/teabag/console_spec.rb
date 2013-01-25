require "spec_helper"
require "teabag/console"

describe Teabag::Console do

  let(:server) { mock(start: nil, url: "http://url.com") }
  subject {
    Teabag::Console.any_instance.stub(:start_server)
    instance = Teabag::Console.new
    instance.instance_variable_set(:@server, server)
    instance
  }

  before do
    subject.instance_variable_set(:@server, server)
    subject.stub(:suites).and_return([:default, :foo])
    Teabag::Environment.stub(:load)
  end

  describe "#initialize" do

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

    it "loads the environment" do
      Teabag::Environment.should_receive(:load).once
      Teabag::Console.new()
    end

    it "starts the server" do
      Teabag::Console.any_instance.should_receive(:start_server).and_call_original
      Teabag::Server.should_receive(:new).and_return(server)
      server.should_receive(:start)
      subject.start_server
      Teabag::Console.new()
    end

  end

  describe "#execute" do

    before do
      STDOUT.stub(:print)
      subject.stub(:run_specs).and_return(0)
    end

    it "assigns @options" do
      options = {foo: "bar"}
      instance = Teabag::Console.new(options)
      expect(instance.instance_variable_get(:@options)).to eql(options)
    end

    it "assigns @files" do
      subject.instance_variable_set(:@files, ["file2"])
      files = ["file1"]
      subject.execute({}, files)
      expect(subject.instance_variable_get(:@files)).to eql(files)
    end

    it "runs the tests" do
      STDOUT.should_receive(:print).with("Teabag running default suite at http://url.com/teabag/default...\n")
      STDOUT.should_receive(:print).with("Teabag running foo suite at http://url.com/teabag/foo...\n")
      subject.should_receive(:run_specs).twice.and_return(2)
      result = subject.execute
      expect(result).to be(true)
    end

    it "tracks the failure count" do
      subject.should_receive(:run_specs).twice.and_return(0)
      result = subject.execute
      expect(result).to be(false)
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
