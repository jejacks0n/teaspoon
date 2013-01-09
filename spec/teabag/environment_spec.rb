require "spec_helper"
require "teabag/environment"

describe Teabag::Environment do

  subject { Teabag::Environment }

  describe ".load" do

    it "calls require_environment if Rails isn't available" do
      subject.should_receive(:rails_loaded?).and_return(false)
      subject.should_receive(:require_environment)
      subject.should_receive(:rails_loaded?).and_return(true)
      Teabag::Environment.load
    end

    it "raises if Rails can't be found" do
      subject.should_receive(:rails_loaded?).twice.and_return(false)
      subject.should_receive(:require_environment)
      expect{ Teabag::Environment.load }.to raise_error("Rails environment not found.")
    end

    it "calls configure_from_options if the environment is ready" do
      subject.should_receive(:rails_loaded?).and_return(true)
      subject.should_receive(:configure_from_options)
      Teabag::Environment.load
    end

  end

  describe ".require_environment" do

    it "allows passing an override" do
      subject.should_receive(:require_env).with(File.expand_path("override", Dir.pwd))
      subject.require_environment("override")
    end

    it "looks for the standard files" do
      subject.stub(:require_env)
      File.should_receive(:exists?).with(File.expand_path("spec/teabag_env.rb", Dir.pwd)).and_return(true)
      subject.should_receive(:require_env).with(File.expand_path("spec/teabag_env.rb", Dir.pwd))
      subject.require_environment

      File.should_receive(:exists?).with(File.expand_path("spec/teabag_env.rb", Dir.pwd)).and_return(false)
      File.should_receive(:exists?).with(File.expand_path("test/teabag_env.rb", Dir.pwd)).and_return(true)
      subject.should_receive(:require_env).with(File.expand_path("test/teabag_env.rb", Dir.pwd))
      subject.require_environment

      File.should_receive(:exists?).with(File.expand_path("spec/teabag_env.rb", Dir.pwd)).and_return(false)
      File.should_receive(:exists?).with(File.expand_path("test/teabag_env.rb", Dir.pwd)).and_return(false)
      File.should_receive(:exists?).with(File.expand_path("teabag_env.rb", Dir.pwd)).and_return(true)
      subject.should_receive(:require_env).with(File.expand_path("teabag_env.rb", Dir.pwd))
      subject.require_environment
    end

    it "raises if no env file was found" do
      File.should_receive(:exists?).any_number_of_times.and_return(false)
      expect{ subject.require_environment }.to raise_error(Teabag::EnvironmentNotFound)
    end
  end

  describe ".standard_environments" do

    it "returns an array" do
      expect(subject.standard_environments).to eql(["spec/teabag_env.rb", "test/teabag_env.rb", "teabag_env.rb"])
    end

  end

  describe ".configure_from_options" do

    before do
      @stored_configuration = Teabag.configuration.color
    end

    after do
      Teabag.configuration.color = @stored_configuration
    end

    it "allows overriding configuration directives from options" do
      Teabag.configuration.color = true
      Teabag::Environment.configure_from_options(color: false)
      expect(Teabag.configuration.color).to be(false)
    end

  end

end
