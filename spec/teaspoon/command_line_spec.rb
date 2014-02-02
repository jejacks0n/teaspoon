require "spec_helper"
require "teaspoon/command_line"
require "teaspoon/console"

describe Teaspoon::CommandLine do

  subject { Teaspoon::CommandLine }

  describe "#initialize" do

    let(:console) { double(failures?: false) }
    let(:parser) { double(parse!: ["file1", "file2"]) }

    before do
      Teaspoon::Console.stub(:new).and_return(console)
      subject.any_instance.stub(:abort)
      subject.any_instance.stub(:opt_parser).and_return(parser)
    end

    it "assigns @options and adds the files that were parsed out" do
      expect(subject.new.instance_variable_get(:@options)).to eq(files: ["file1", "file2"])
    end

    it "aborts with a message on Teaspoon::EnvironmentNotFound" do
      Teaspoon::Console.should_receive(:new).and_raise(Teaspoon::EnvironmentNotFound)
      subject.any_instance.should_receive(:abort).with("Teaspoon::EnvironmentNotFound\nConsider using -r path/to/teaspoon_env\n")
      subject.new
    end

    it "executes using Teaspoon::Console" do
      Teaspoon::Console.should_receive(:new).with(files: ["file1", "file2"])
      console.should_receive(:failures?)
      subject.new
    end

    it "aborts if Teaspoon::Console fails" do
      subject.any_instance.should_receive(:abort)
      console.should_receive(:failures?).and_return(true)
      subject.new
    end

  end

end
