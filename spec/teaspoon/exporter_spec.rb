require "spec_helper"
require "teaspoon/exporter"

describe Teaspoon::Exporter do
  subject { described_class.new(:suite_name, "http://666.420.42.0:31337/url/to/teaspoon", "_output_path_") }

  describe "#initialize" do
    it "assigns @suite and @url" do
      expect(subject.instance_variable_get(:@suite)).to eq(:suite_name)
      expect(subject.instance_variable_get(:@url)).to eq("http://666.420.42.0:31337/url/to/teaspoon")
    end

    it "expands the @output_path" do
      expected = File.join(File.expand_path("_output_path_"), "suite_name")
      expect(subject.instance_variable_get(:@output_path)).to eq(expected)
    end
  end

  describe "#export" do
    before do
      expect(Dir).to receive(:mktmpdir).and_yield("_temp_path_")
      allow(subject).to receive(:executable).and_return("/path/to/executable")
      allow(subject).to receive(:`)
    end

    it "makes a temp directory and cds to it" do
      expect(Dir).to receive(:chdir).with("_temp_path_")
      subject.export
    end

    it "executes the wget call and creates the export" do
      stub_exit_code(ExitCodes::SUCCESS)
      expect(Dir).to receive(:chdir).with("_temp_path_").and_yield
      opts = "--convert-links --adjust-extension --page-requisites --span-hosts"
      expect(subject).to receive(:`).with("/path/to/executable #{opts} http://666.420.42.0:31337/url/to/teaspoon 2>&1")
      expect(subject).to receive(:create_export).with("_temp_path_/666.420.42.0:31337")
      subject.export
    end

    it "raises an exception if the command failed for some reason" do
      stub_exit_code(ExitCodes::EXCEPTION)
      expect(Dir).to receive(:chdir).with("_temp_path_").and_yield
      expect { subject.export }.to raise_error(
        Teaspoon::DependencyError,
        "Unable to export suite_name suite."
      )
    end

    it "raises an exception if wget wasn't found" do
      expect(Dir).to receive(:chdir).with("_temp_path_").and_yield
      expect(subject).to receive(:executable).and_call_original
      expect(subject).to receive(:which).with("wget").and_return(nil)
      expect { subject.export }.to raise_error(
        Teaspoon::MissingDependencyError,
        "Unable to locate `wget` for exporter."
      )
    end

    describe "creating the export" do
      before do
        stub_exit_code(ExitCodes::SUCCESS)
        expect(Dir).to receive(:chdir).with("_temp_path_").and_yield
        expect(Dir).to receive(:chdir).with("_temp_path_/666.420.42.0:31337").and_yield

        allow(File).to receive(:read).and_return("")
        allow(File).to receive(:write)
        allow(FileUtils).to receive(:mkdir_p)
        allow(FileUtils).to receive(:rm_r)
        allow(FileUtils).to receive(:mv)
      end

      it "updates the relative paths" do
        expect(File).to receive(:read).with(".#{Teaspoon.configuration.mount_at}/suite_name.html").
          and_return('"../../path/to/asset')
        expect(File).to receive(:write).with("index.html", '"../path/to/asset')
        subject.export
      end

      it "cleans up the old files" do
        allow(subject).to receive(:move_output)
        expect(Dir).to receive(:[]).once.with("{.#{Teaspoon.configuration.mount_at},robots.txt.html}").
          and_return(["./teaspoon", "robots.txt.html"])
        expect(FileUtils).to receive(:rm_r).with(["./teaspoon", "robots.txt.html"])
        subject.export
      end

      it "moves the files into the output path" do
        allow(subject).to receive(:cleanup_output)
        output_path = subject.instance_variable_get(:@output_path)
        expect(Dir).to receive(:[]).and_return(["1", "2"])
        expect(FileUtils).to receive(:mkdir_p).with(output_path)
        expect(FileUtils).to receive(:mv).with(["1", "2"], output_path, force: true)
        subject.export
      end
    end
  end
end
