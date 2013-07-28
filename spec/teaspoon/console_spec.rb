require "spec_helper"
require "teaspoon/console"

describe Teaspoon::Console do

  let(:server) { double(start: nil, url: "http://url.com") }
  subject {
    Teaspoon::Console.any_instance.stub(:start_server)
    instance = Teaspoon::Console.new
    instance.instance_variable_set(:@server, server)
    instance
  }

  before do
    subject.instance_variable_set(:@server, server)
    Teaspoon::Environment.stub(:load)
  end

  describe "#initialize" do

    it "assigns @options" do
      options = {foo: "bar"}
      instance = Teaspoon::Console.new(options)
      expect(instance.instance_variable_get(:@options)).to eql(options)
    end

    it "loads the environment" do
      Teaspoon::Environment.should_receive(:load).once
      Teaspoon::Console.new()
    end

    it "starts the server" do
      Teaspoon::Console.any_instance.should_receive(:start_server).and_call_original
      Teaspoon::Server.should_receive(:new).and_return(server)
      server.should_receive(:start)
      subject.start_server
      Teaspoon::Console.new()
    end

    it "resolves the files" do
      files = ["file1"]
      Teaspoon::Console.any_instance.should_receive(:resolve).with(files)
      Teaspoon::Console.new(nil, files)
    end

  end

  describe "#execute" do

    before do
      STDOUT.stub(:print)
      subject.stub(:run_specs).and_return(0)
    end

    it "assigns @options" do
      options = {foo: "bar"}
      instance = Teaspoon::Console.new(options)
      expect(instance.instance_variable_get(:@options)).to eql(options)
    end

    it "resolves the files" do
      files = ["file2"]
      Teaspoon::Suite.should_receive(:resolve_spec_for).with("file2").and_return(suite: "foo", path: "file2")
      subject.execute(nil, files)
      expect(subject.instance_variable_get(:@files)).to eq(files)

      suites = subject.send(:suites)
      expect(suites).to eq(["foo"])
      expect(subject.send(:filter, "foo")).to eq("file[]=file2")
    end

    it "resolves the files if a directory was given" do
      directory = [ "test/javascripts" ]
      resolve_spec_for_output = ['test/javascripts/foo.coffee', 'test/javascripts/bar.coffee']
      Teaspoon::Suite.should_receive(:resolve_spec_for).with("test/javascripts").and_return(suite: "foo", path: resolve_spec_for_output)
      subject.execute(nil, directory)
      expect(subject.instance_variable_get(:@files)).to eq(directory)

      suites = subject.send(:suites)
      expect(suites).to eq(["foo"])
      expect(subject.send(:filter, "foo")).to eq("file[]=#{resolve_spec_for_output.join('&file[]=')}")
    end

    it "runs the tests" do
      subject.should_receive(:suites).and_return([:default, :foo])
      STDOUT.should_receive(:print).with("Teaspoon running default suite at http://url.com/teaspoon/default\n")
      STDOUT.should_receive(:print).with("Teaspoon running foo suite at http://url.com/teaspoon/foo\n")
      subject.should_receive(:run_specs).twice.and_return(2)
      result = subject.execute
      expect(result).to be(true)
    end

    it "tracks the failure count" do
      subject.should_receive(:suites).and_return([:default, :foo])
      subject.should_receive(:run_specs).twice.and_return(0)
      result = subject.execute
      expect(result).to be(false)
    end

  end

  describe "#run_specs" do

    it "calls run_specs on the driver" do
      driver = double(run_specs: nil)
      subject.should_receive(:driver).and_return(driver)
      driver.should_receive(:run_specs).with(:suite_name, "http://url.com/teaspoon/suite_name?reporter=Console", nil)
      subject.run_specs(:suite_name)
    end

  end

end
