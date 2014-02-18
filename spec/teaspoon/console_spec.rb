require "spec_helper"
require "teaspoon/console"
require "teaspoon/server"
require "teaspoon/runner"
require "teaspoon/exporter"

describe Teaspoon::Console do

  let(:driver) { double(run_specs: 0) }
  let(:server) { double(start: nil, url: "http://url.com") }
  let(:runner) { double(failure_count: 2) }

  before do
    Teaspoon::Environment.stub(:load)
    Teaspoon::Server.stub(:new).and_return(server)
    Teaspoon::Runner.stub(:new).and_return(runner)

    Teaspoon::Console.any_instance.stub(:driver).and_return(driver)
    Teaspoon::Console.any_instance.stub(:log)
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
      Teaspoon::Console.any_instance.should_receive(:log).with("Starting the Teaspoon server...")
      Teaspoon::Console.any_instance.should_receive(:start_server).and_call_original
      Teaspoon::Server.should_receive(:new).and_return(server)
      server.should_receive(:start)
      Teaspoon::Console.new
    end

    it "aborts (displaying a message) on Teaspoon::ServerException" do
      STDOUT.should_receive(:print).with("_message_\n")
      Teaspoon::Console.any_instance.should_receive(:log).and_call_original
      Teaspoon::Console.any_instance.should_receive(:start_server).and_raise(Teaspoon::ServerException, "_message_")
      Teaspoon::Console.any_instance.should_receive(:abort).with("_message_").and_call_original
      expect{ Teaspoon::Console.new }.to raise_error SystemExit
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

    it "handles Teaspoon::Error exceptions" do
      subject.should_receive(:abort).with("_unknown_error_")
      subject.should_receive(:execute_without_handling).and_raise(Teaspoon::Error, "_unknown_error_")
      subject.execute
    end

    it "returns false on Teaspoon::Failure" do
      subject.should_receive(:execute_without_handling).and_raise(Teaspoon::Failure)
      expect(subject.execute).to be_false
    end

  end

  describe "#execute_without_handling" do

    before do
      subject.stub(:run_specs).and_return(0)
      subject.stub(:export)
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
      subject.should_receive(:run_specs).twice.and_return(2)
      expect(subject.execute_without_handling).to be_false
    end

    it "returns true if no failure count" do
      subject.should_receive(:suites).and_return([:default, :foo])
      subject.should_receive(:run_specs).twice.and_return(0)
      expect(subject.execute_without_handling).to be_true
    end

    it "returns true if there were failures" do
      subject.should_receive(:suites).and_return([:default])
      subject.should_receive(:run_specs).once.and_return(1)
      expect(subject.execute_without_handling).to be_false
    end

    it "calls export if the options include :export" do
      subject.should_receive(:suites).and_return([:default, :foo])
      subject.instance_variable_set(:@options, export: true)
      subject.should_receive(:export).with(:default)
      subject.should_receive(:export).with(:foo)
      subject.execute
    end

  end

  describe "#run_specs" do

    before do
      Teaspoon.configuration.stub(:fail_fast).and_return(false)
      Teaspoon.configuration.should_receive(:suite_configs).and_return("_suite_" => proc{}, "suite_name" => proc{})
    end

    it "raises a Teaspoon::UnknownSuite exception when the suite isn't known" do
      expect { subject.run_specs("_unknown_") }.to raise_error Teaspoon::UnknownSuite
    end

    it "logs that the suite is being run" do
      subject.should_receive(:log).with("Teaspoon running _suite_ suite at http://url.com/teaspoon/_suite_")
      subject.run_specs("_suite_")
    end

    it "calls #run_specs on the driver" do
      subject.should_receive(:driver).and_return(driver)
      driver.should_receive(:run_specs).with(runner, "http://url.com/teaspoon/suite_name?reporter=Console")
      expect(subject.run_specs(:suite_name)).to eq(2)
    end

    it "raises a Teaspoon::Failure exception on failures when set to fail_fast" do
      Teaspoon.configuration.stub(:fail_fast).and_return(true)
      expect { subject.run_specs(:suite_name) }.to raise_error Teaspoon::Failure
    end

    it "raises a Teaspoon:UnknownDriver when an unknown driver is being used" do
      Teaspoon.configuration.should_receive(:driver).twice.and_return(:foo)
      subject.should_receive(:driver).and_call_original
      expect { subject.run_specs(:suite_name) }.to raise_error Teaspoon::UnknownDriver
    end

  end

  describe "#export" do

    before do
      Teaspoon.configuration.should_receive(:suite_configs).and_return("_suite_" => proc{}, "suite_name" => proc{})
      Teaspoon::Exporter.stub(:new).and_return(double(export: nil))
    end

    it "raises a Teaspoon::UnknownSuite exception when the suite isn't known" do
      expect { subject.export("_unknown_") }.to raise_error Teaspoon::UnknownSuite
    end

    it "logs that the suite is being exported" do
      subject.should_receive(:log).with("Teaspoon exporting _suite_ suite at http://url.com/teaspoon/_suite_")
      subject.export("_suite_")
    end

    it "calls #export on the exporter" do
      subject.instance_variable_set(:@options, export: "_output_path_")
      exporter = double(export: nil)
      Teaspoon::Exporter.should_receive(:new).with("_suite_", "http://url.com/teaspoon/_suite_", "_output_path_").and_return(exporter)
      exporter.should_receive(:export)
      subject.export("_suite_")
    end

  end

end
