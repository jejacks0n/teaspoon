require "spec_helper"
require "teabag/command_line"
require "teabag/console"

describe Teabag::CommandLine do

  describe "#initialize" do

    let(:console) { mock(execute: false) }
    let(:parser) { mock(parse!: ["file1", "file2"]) }

    before do
      Teabag::CommandLine.any_instance.stub(:abort)
      Teabag::Console.stub(:new).and_return(console)
      Teabag::CommandLine.any_instance.stub(:opt_parser).and_return(parser)
    end

    it "assigns @options" do
      instance = Teabag::CommandLine.new
      expect(instance.instance_variable_get(:@options)).to eq({})
    end

    it "assigns @files" do
      instance = Teabag::CommandLine.new
      expect(instance.instance_variable_get(:@files)).to eq(["file1", "file2"])
    end

    it "aborts with a message on Teabag::EnvironmentNotFound" do
      Teabag::CommandLine.any_instance.should_receive(:require_console).and_raise(Teabag::EnvironmentNotFound)
      Teabag::CommandLine.any_instance.should_receive(:abort)
      STDOUT.should_receive(:print).with("Unable to load Teabag environment in {spec/teabag_env.rb, test/teabag_env.rb, teabag_env.rb}.\n")
      STDOUT.should_receive(:print).with("Consider using -r path/to/teabag_env\n")
      Teabag::CommandLine.new
    end

    it "executes using Teabag::Console" do
      Teabag::Console.should_receive(:new).with({}, ["file1", "file2"])
      console.should_receive(:execute)
      Teabag::CommandLine.new
    end

    it "aborts if Teabag::Console fails" do
      Teabag::CommandLine.any_instance.should_receive(:abort)
      console.should_receive(:execute).and_return(true)
      Teabag::CommandLine.new
    end

  end

end
