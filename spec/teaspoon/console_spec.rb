require "spec_helper"
require "teaspoon/console"
require "teaspoon/server"

describe Teaspoon::Console do

  let(:driver) { double(run_specs: 0) }
  let(:server) { double(start: nil, url: "http://url.com") }

  before do
    Teaspoon::Console.any_instance.stub(:driver).and_return(driver)
    Teaspoon::Console.any_instance.stub(:start_server).and_return(server)
    Teaspoon::Environment.stub(:load)
  end

  describe "#initialize" do

    it "assigns @options" do
      subject = Teaspoon::Console.new(foo: "bar")
      expect(subject.instance_variable_get(:@options)).to eql(foo: "bar")
    end

    it "loads the environment" do
      Teaspoon::Environment.should_receive(:load)
      Teaspoon::Console.new
    end

    it "starts the server" do
      Teaspoon::Console.any_instance.should_receive(:start_server).and_call_original
      Teaspoon::Server.should_receive(:new).and_return(server)
      server.should_receive(:start)
      Teaspoon::Console.new
    end

  end

  describe "#failures?" do

    it "calls #execute and returns the inverse of #executes return value" do
      subject.should_receive(:execute).and_return(false)
      expect(subject.failures?).to be_true

      subject.should_receive(:execute).and_return(true)
      expect(subject.failures?).to be_false
    end

  end

  describe "#execute" do

    it "calls #execute_without_handling and returns its value" do
      subject.should_receive(:execute_without_handling).with(foo: "bar").and_return(true)
      expect(subject.execute(foo: "bar")).to be_true
    end

    it "handles exceptions for UnknownDriver, UnknownFormatter, and RunnerException by aborting" do
      subject.should_receive(:abort).with("_unknown_driver_message_")
      subject.should_receive(:execute_without_handling).and_raise(Teaspoon::UnknownDriver, "_unknown_driver_message_")
      subject.execute

      subject.should_receive(:abort).with("_unknown_formatter_message_")
      subject.should_receive(:execute_without_handling).and_raise(Teaspoon::UnknownFormatter, "_unknown_formatter_message_")
      subject.execute

      subject.should_receive(:abort).with("_runner_exception_")
      subject.should_receive(:execute_without_handling).and_raise(Teaspoon::RunnerException, "_runner_exception_")
      subject.execute
    end

    it "returns false on Teaspoon::Failure" do
      subject.should_receive(:execute_without_handling).and_raise(Teaspoon::Failure)
      expect(subject.execute).to be_false
    end

  end

  describe "#execute_without_handling" do

    before do
      subject.stub(:log)
    end

    it "merges @options" do
      subject.instance_variable_set(:@options, foo: "bar")
      subject.execute_without_handling(bar: "baz")
      expect(subject.instance_variable_get(:@options)).to eql(foo: "bar", bar: "baz")
    end

    it "clears any @suites" do
      subject.instance_variable_set(:@suites, foo: "bar")
      subject.execute_without_handling
      expect(subject.instance_variable_get(:@suites)).to eql({})
    end

    it "resolves the files" do
      Teaspoon::Suite.should_receive(:resolve_spec_for).with("file").and_return(suite: "foo", path: "file2")
      subject.execute_without_handling(files: ["file"])

      expect(subject.send(:suites)).to eq(["foo"])
      expect(subject.send(:filter, "foo")).to eq("file[]=file2")
    end

    it "resolves the files if a directory was given" do
      resolve_spec_for_output = ['test/javascripts/foo.coffee', 'test/javascripts/bar.coffee']
      Teaspoon::Suite.should_receive(:resolve_spec_for).with("full/path").and_return(suite: "foo", path: resolve_spec_for_output)
      subject.execute_without_handling(files: ["full/path"])
      expect(subject.send(:suites)).to eq(["foo"])
      expect(subject.send(:filter, "foo")).to eq("file[]=#{resolve_spec_for_output.join('&file[]=')}")
    end

    it "runs the tests" do
      subject.should_receive(:suites).and_return([:default, :foo])
      subject.should_receive(:log).with("Teaspoon running default suite at http://url.com/teaspoon/default")
      subject.should_receive(:log).with("Teaspoon running foo suite at http://url.com/teaspoon/foo")
      subject.should_receive(:run_specs).twice.and_return(2)
      expect(subject.execute_without_handling).to be_false
    end

    it "returns true if no failure count" do
      subject.should_receive(:suites).and_return([:default, :foo])
      subject.should_receive(:run_specs).twice.and_return(0)
      expect(subject.execute_without_handling).to be_true
    end

    it "returns true if there were failures" do
      subject.should_receive(:suites).and_return([:default, :foo])
      subject.should_receive(:run_specs).twice.and_return(1)
      expect(subject.execute_without_handling).to be_false
    end

    it "exports the tests when the :export option is given" do
      subject.stub(:suites => [:default])
      subject.instance_variable_set(:@options, {:export => true})
      export = double(:export, :output_path => '/output/path')
      Teaspoon::Export.stub(:new => export)
      expect(export).to receive(:execute)
      subject.execute
    end

  end

  describe "#run_specs" do

    it "calls #run_specs on the driver" do
      subject.should_receive(:driver).and_return(driver)
      driver.should_receive(:run_specs).with(:suite_name, "http://url.com/teaspoon/suite_name?reporter=Console")
      subject.run_specs(:suite_name)
    end

  end

end
