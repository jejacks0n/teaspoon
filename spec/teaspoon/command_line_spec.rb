require "spec_helper"
require "teaspoon/command_line"
require "teaspoon/console"

describe Teaspoon::CommandLine do

  describe "#initialize" do

    let(:console) { double(execute: false) }
    let(:parser) { double(parse!: ["file1", "file2"]) }

    before do
      Teaspoon::CommandLine.any_instance.stub(:abort)
      Teaspoon::Console.stub(:new).and_return(console)
      Teaspoon::CommandLine.any_instance.stub(:opt_parser).and_return(parser)
    end

    it "assigns @options" do
      instance = Teaspoon::CommandLine.new
      expect(instance.instance_variable_get(:@options)).to eq(files: ["file1", "file2"])
    end

    it "aborts with a message on Teaspoon::EnvironmentNotFound" do
      Teaspoon::Console.should_receive(:new).and_raise(Teaspoon::EnvironmentNotFound)
      Teaspoon::CommandLine.any_instance.should_receive(:abort)
      STDOUT.should_receive(:print).with("Unable to load Teaspoon environment in {spec/teaspoon_env.rb, test/teaspoon_env.rb, teaspoon_env.rb}.\n")
      STDOUT.should_receive(:print).with("Consider using -r path/to/teaspoon_env\n")
      Teaspoon::CommandLine.new
    end

    it "executes using Teaspoon::Console" do
      Teaspoon::Console.should_receive(:new).with(files: ["file1", "file2"])
      console.should_receive(:execute)
      Teaspoon::CommandLine.new
    end

    it "aborts if Teaspoon::Console fails" do
      Teaspoon::CommandLine.any_instance.should_receive(:abort)
      console.should_receive(:execute).and_return(true)
      Teaspoon::CommandLine.new
    end

  end

end
