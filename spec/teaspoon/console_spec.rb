require "spec_helper"
require "teaspoon/console"
require "teaspoon/server"
require "teaspoon/runner"
require "teaspoon/exporter"

describe Teaspoon::Console do
  let(:driver) { double(run_specs: 0) }
  let(:server) { double(start: nil, url: "http://url.com", responsive?: false) }
  let(:runner) { double(failure_count: 2) }

  before do
    allow(Teaspoon::Environment).to receive(:load)
    allow(Teaspoon::Server).to receive(:new).and_return(server)
    allow(Teaspoon::Runner).to receive(:new).and_return(runner)

    allow_any_instance_of(described_class).to receive(:driver).and_return(driver)
    allow_any_instance_of(described_class).to receive(:log)
  end

  describe "#initialize" do
    it "assigns @default_options" do
      subject = described_class.new(foo: "bar")
      expect(subject.instance_variable_get(:@default_options)).to eql(foo: "bar")
    end

    it "ensures an env file exists" do
      expect(Teaspoon::Environment).to receive(:check_env!)
      described_class.new
    end

    it "loads the environment" do
      expect(Teaspoon::Environment).to receive(:load)
      described_class.new
    end

    it "starts the server" do
      expect(STDOUT).to receive(:print).with("Starting the Teaspoon server...\n")
      expect_any_instance_of(described_class).to receive(:log).with("Starting the Teaspoon server...").and_call_original
      expect_any_instance_of(described_class).to receive(:start_server) .and_call_original
      expect(Teaspoon::Server).to receive(:new).and_return(server)
      expect(server).to receive(:start)
      described_class.new
    end

    it "does not log a message about starting the server if one has already been started" do
      allow(server).to receive(:responsive?).and_return(true)
      expect_any_instance_of(described_class).not_to receive(:log).with("Starting the Teaspoon server...")
      described_class.new
    end

    it "aborts (displaying a message) on Teaspoon::ServerError" do
      expect(Teaspoon).to receive(:abort).with("_message_")
      expect_any_instance_of(described_class).to receive(:start_server).
        and_raise(Teaspoon::ServerError, "_message_")
      described_class.new
    end
  end

  describe "#failures?" do
    it "calls #execute and returns the inverse of #executes return value" do
      expect(subject).to receive(:execute).and_return(false)
      expect(subject.failures?).to be_truthy

      expect(subject).to receive(:execute).and_return(true)
      expect(subject.failures?).to be_falsey
    end
  end

  describe "#execute" do
    it "calls #execute_without_handling and returns its value" do
      expect(subject).to receive(:execute_without_handling).with(foo: "bar").and_return(true)
      expect(subject.execute(foo: "bar")).to be_truthy
    end

    it "handles Teaspoon::RunnerException exceptions" do
      expect(subject).to receive(:log).with("_runner_error_")
      expect(subject).to receive(:execute_without_handling).
        and_raise(Teaspoon::RunnerError, "_runner_error_")
      expect(subject.execute).to be_falsey
    end

    it "handles Teaspoon::Error exceptions" do
      expect(Teaspoon).to receive(:abort).with("_unknown_error_")
      expect(subject).to receive(:execute_without_handling).
        and_raise(Teaspoon::Error, "_unknown_error_")
      subject.execute
    end

    it "returns false on Teaspoon::Failure" do
      expect(subject).to receive(:execute_without_handling).
        and_raise(Teaspoon::Failure)
      expect(subject.execute).to be_falsey
    end
  end

  describe "#execute_without_handling" do
    before do
      allow(subject).to receive(:run_specs).and_return(0)
      allow(subject).to receive(:export)
    end

    it "merges options" do
      subject.instance_variable_set(:@default_options, foo: "bar")
      subject.execute_without_handling(bar: "baz")
      expect(subject.options).to eql(foo: "bar", bar: "baz")
    end

    it "clears any @suites" do
      subject.instance_variable_set(:@suites, foo: "bar")
      subject.execute_without_handling
      expect(subject.instance_variable_get(:@suites)).to eql({})
    end

    it "resolves the files" do
      expect(Teaspoon::Suite).to receive(:resolve_spec_for).with("file").
        and_return(suite: "foo", path: "file2")
      subject.execute_without_handling(files: ["file"])

      expect(subject.send(:suites)).to eq(["foo"])
      expect(subject.send(:filter, "foo")).to eq("file[]=file2")
    end

    it 'resolves suites if multiple are given' do
      subject.execute_without_handling(suite: 'bar,foo')
      expect(subject.send(:suites)).to eq(%w(foo bar))

      subject.execute_without_handling(suite: 'foo')
      expect(subject.send(:suites)).to eq(%w(foo))
    end

    it "resolves the files if a directory was given" do
      resolve_spec_for_output = ["test/javascripts/foo.coffee", "test/javascripts/bar.coffee"]
      expect(Teaspoon::Suite).to receive(:resolve_spec_for).with("full/path").
        and_return(suite: "foo", path: resolve_spec_for_output)
      subject.execute_without_handling(files: ["full/path"])
      expect(subject.send(:suites)).to eq(["foo"])
      expect(subject.send(:filter, "foo")).to eq("file[]=#{resolve_spec_for_output.join('&file[]=')}")
    end

    it "runs the tests" do
      expect(subject).to receive(:suites).and_return([:default, :foo])
      expect(subject).to receive(:run_specs).twice.and_return(2)
      expect(subject.execute_without_handling).to be_falsey
    end

    it "returns true if no failure count" do
      expect(subject).to receive(:suites).and_return([:default, :foo])
      expect(subject).to receive(:run_specs).twice.and_return(0)
      expect(subject.execute_without_handling).to be_truthy
    end

    it "returns true if there were failures" do
      expect(subject).to receive(:suites).and_return([:default])
      expect(subject).to receive(:run_specs).once.and_return(1)
      expect(subject.execute_without_handling).to be_falsey
    end

    it "calls export if the options include :export" do
      expect(subject).to receive(:suites).and_return([:default, :foo])
      subject.instance_variable_set(:@default_options, export: true)
      expect(subject).to receive(:export).with(:default)
      expect(subject).to receive(:export).with(:foo)
      subject.execute
    end
  end

  describe "#run_specs" do
    before do
      allow(Teaspoon.configuration).to receive(:fail_fast).and_return(false)
      expect(Teaspoon.configuration).to receive(:suite_configs).
        and_return("_suite_" => proc {}, "suite_name" => proc {})
    end

    it "raises an exception when the suite isn't known" do
      expect { subject.run_specs("_unknown_") }.to raise_error(
        Teaspoon::UnknownSuite,
        "Unknown suite configuration: expected \"_unknown_\" to be a configured suite."
      )
    end

    it "logs that the suite is being run" do
      expect(subject).to receive(:log).with("Teaspoon running _suite_ suite at http://url.com/teaspoon/_suite_")
      subject.run_specs("_suite_")
    end

    it "calls #run_specs on the driver" do
      expect(subject).to receive(:driver).and_return(driver)
      expect(driver).to receive(:run_specs).with(runner, "http://url.com/teaspoon/suite_name?reporter=Console")
      expect(subject.run_specs(:suite_name)).to eq(2)
    end

    it "raises an exception on failures when set to fail_fast" do
      allow(Teaspoon.configuration).to receive(:fail_fast).and_return(true)
      expect { subject.run_specs(:suite_name) }.to raise_error(
        Teaspoon::Failure
      )
    end
  end

  describe "#export" do
    before do
      expect(Teaspoon.configuration).to receive(:suite_configs).
        and_return("_suite_" => proc {}, "suite_name" => proc {})
      allow(Teaspoon::Exporter).to receive(:new).and_return(double(export: nil))
    end

    it "raises an exception when the suite isn't known" do
      expect { subject.export("_unknown_") }.to raise_error(
        Teaspoon::UnknownSuite,
        "Unknown suite configuration: expected \"_unknown_\" to be a configured suite."
      )
    end

    it "logs that the suite is being exported" do
      expect(subject).to receive(:log).with("Teaspoon exporting _suite_ suite at http://url.com/teaspoon/_suite_")
      subject.export("_suite_")
    end

    it "calls #export on the exporter" do
      subject.instance_variable_set(:@default_options, export: "_output_path_")
      exporter = double(export: nil)
      expect(Teaspoon::Exporter).to receive(:new).with("_suite_", "http://url.com/teaspoon/_suite_", "_output_path_").
        and_return(exporter)
      expect(exporter).to receive(:export)
      subject.export("_suite_")
    end
  end
end
