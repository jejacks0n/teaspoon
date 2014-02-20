require "spec_helper"
require "teaspoon/exporter"

describe Teaspoon::Exporter do

  subject { Teaspoon::Exporter.new(:suite_name, "http://666.420.42.0:31337/url/to/teaspoon", "_output_path_") }

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
      Dir.should_receive(:mktmpdir).and_yield("_temp_path_")
      subject.stub(:executable).and_return("/path/to/executable")
      subject.stub(:`)
    end

    it "makes a temp directory and cds to it" do
      Dir.should_receive(:chdir).with("_temp_path_")
      subject.export
    end

    it "executes the wget call and creates the export" do
      `(exit 0)`
      Dir.should_receive(:chdir).with("_temp_path_").and_yield
      subject.should_receive(:`).with("/path/to/executable --convert-links --adjust-extension --page-requisites --span-hosts http://666.420.42.0:31337/url/to/teaspoon 2>&1")
      subject.should_receive(:create_export).with("_temp_path_/666.420.42.0:31337")
      subject.export
    end

    it "raises a Teaspoon::ExporterException if the command failed for some reason" do
      `(exit 1)`
      Dir.should_receive(:chdir).with("_temp_path_").and_yield
      expect { subject.export }.to raise_error Teaspoon::ExporterException, "Unable to export suite_name suite."
    end

    it "raises a Teaspoon::MissingDependency if wget wasn't found" do
      Dir.should_receive(:chdir).with("_temp_path_").and_yield
      subject.should_receive(:executable).and_call_original
      subject.should_receive(:which).with("wget").and_return(nil)
      expect { subject.export }.to raise_error Teaspoon::MissingDependency, "Could not find wget for exporting."
    end

    describe "creating the export" do

      before do
        `(exit 0)`
        Dir.should_receive(:chdir).with("_temp_path_").and_yield
        Dir.should_receive(:chdir).with("_temp_path_/666.420.42.0:31337").and_yield

        File.stub(:read).and_return("")
        File.stub(:write)
        FileUtils.stub(:mkdir_p)
        FileUtils.stub(:rm_r)
        FileUtils.stub(:mv)
      end

      it "updates the relative paths" do
        File.should_receive(:read).with(".#{Teaspoon.configuration.mount_at}/suite_name.html").and_return('"../../path/to/asset')
        File.should_receive(:write).with("index.html", '"../path/to/asset')
        subject.export
      end

      it "cleans up the old files" do
        subject.stub(:move_output)
        Dir.should_receive(:[]).once.with("{.#{Teaspoon.configuration.mount_at},robots.txt.html}").and_return(["./teaspoon", "robots.txt.html"])
        FileUtils.should_receive(:rm_r).with(["./teaspoon", "robots.txt.html"])
        subject.export
      end

      it "moves the files into the output path" do
        subject.stub(:cleanup_output)
        output_path = subject.instance_variable_get(:@output_path)
        Dir.should_receive(:[]).and_return(["1", "2"])
        FileUtils.should_receive(:mkdir_p).with(output_path)
        FileUtils.should_receive(:mv).with(["1", "2"], output_path, force: true)
        subject.export
      end

    end

  end

end
