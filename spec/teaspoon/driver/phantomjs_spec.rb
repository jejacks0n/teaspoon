require "spec_helper"

describe Teaspoon::Driver.fetch(:phantomjs) do

  describe "#initialize" do
    it "assigns @options" do
      subject = described_class.new(foo: "bar")
      expect(subject.instance_variable_get(:@options)).to eq(["--foo=bar"])
    end

    it "accepts a string for options" do
      subject = described_class.new("--foo=bar --bar=baz")
      expect(subject.instance_variable_get(:@options)).to eq(["--foo=bar", "--bar=baz"])
    end

    it "accepts an array for options" do
      subject = described_class.new(["--foo=bar", "--bar=baz"])
      expect(subject.instance_variable_get(:@options)).to eq(["--foo=bar", "--bar=baz"])
    end

    it "raises an exception if the options aren't understood" do
      expect { described_class.new(true) }.to raise_error(
        Teaspoon::DriverOptionsError,
        "Malformed driver options: expected a valid string, array or hash."
      )
    end
  end

  describe "#run_specs" do
    before do
      # Stub phantom
      allow(::IO).to receive(:popen) { `(exit 0)` }
    end

    context "with phantomjs" do
      let(:runner) { double }

      it "calls #run and calls runner.process with each line of output" do
        subject.instance_variable_set(:@options, ["--foo", "--bar"])
        script = Teaspoon::Engine.root.join("lib/teaspoon/driver/phantomjs/runner.js").to_s
        args = ["--foo", "--bar", script.inspect, '"_url_"', 180]

        expect(subject).to receive(:run).with(*args) { |&b| @block = b }
        expect(runner).to receive(:process).with("_line_")
        subject.run_specs(runner, "_url_")
        @block.call("_line_")
      end
    end

    context "without phantomjs" do
      before do
        allow(subject).to receive(:which).and_return(nil)
      end

      it "checks for the Phantomjs gem" do
        stub_const("Phantomjs", double(path: '/path/to/phantomjs'))

        expect(::Phantomjs).to receive(:path)
        expect(::IO).to receive(:popen)
        expect { subject.run_specs(:default, "_url_") }.not_to raise_error
      end

      it "raises an exception" do
        expect { subject.run_specs(:default, "_url_") }.to raise_error(
          Teaspoon::MissingDependencyError,
          "Unable to locate phantomjs. Install it or use the phantomjs gem."
        )
      end
    end

    context "with a broken phantomjs" do
      before do
        allow(::IO).to receive(:popen) { `(exit 1)` }
      end

      it "raises an exception" do
        expect { subject.run_specs(:default, "_url_") }.to raise_error(
          Teaspoon::DependencyError,
          "Failed to use phantomjs, which exited with status code: 1"
        )
      end
    end
  end
end
