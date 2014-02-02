require "spec_helper"
require "teaspoon/environment"

describe Teaspoon::Environment do

  subject { Teaspoon::Environment }

  describe ".load" do

    it "calls require_environment" do
      subject.should_receive(:require_environment)
      subject.should_receive(:rails_loaded?).and_return(true)
      Teaspoon::Environment.load
    end

    it "raises if Rails can't be found" do
      subject.should_receive(:require_environment)
      subject.should_receive(:rails_loaded?).and_return(false)
      expect{ Teaspoon::Environment.load }.to raise_error("Rails environment not found.")
    end

    it "configures teaspoon from options if the environment is ready" do
      subject.should_receive(:rails_loaded?).and_return(true)
      Teaspoon.configuration.should_receive(:override_from_options).with(foo: "bar")
      Teaspoon::Environment.load(foo: "bar")
    end

  end

  describe ".require_environment" do

    before do
      File.stub(:exists?)
      subject.stub(:require_env)
    end

    it "allows passing an override" do
      subject.should_receive(:require_env).with(File.expand_path("_override_", Dir.pwd))
      subject.require_environment("_override_")
    end

    it "looks for the standard files" do
      File.should_receive(:exists?).with(File.expand_path("spec/teaspoon_env.rb", Dir.pwd)).and_return(true)
      subject.should_receive(:require_env).with(File.expand_path("spec/teaspoon_env.rb", Dir.pwd))
      subject.require_environment

      File.should_receive(:exists?).with(File.expand_path("spec/teaspoon_env.rb", Dir.pwd)).and_return(false)
      File.should_receive(:exists?).with(File.expand_path("test/teaspoon_env.rb", Dir.pwd)).and_return(true)
      subject.should_receive(:require_env).with(File.expand_path("test/teaspoon_env.rb", Dir.pwd))
      subject.require_environment

      File.should_receive(:exists?).with(File.expand_path("spec/teaspoon_env.rb", Dir.pwd)).and_return(false)
      File.should_receive(:exists?).with(File.expand_path("test/teaspoon_env.rb", Dir.pwd)).and_return(false)
      File.should_receive(:exists?).with(File.expand_path("teaspoon_env.rb", Dir.pwd)).and_return(true)
      subject.should_receive(:require_env).with(File.expand_path("teaspoon_env.rb", Dir.pwd))
      subject.require_environment
    end

    it "raises if no env file was found" do
      expect{ subject.require_environment }.to raise_error(Teaspoon::EnvironmentNotFound)
    end

  end

  describe ".standard_environments" do

    it "returns an array" do
      expect(subject.standard_environments).to eql(["spec/teaspoon_env.rb", "test/teaspoon_env.rb", "teaspoon_env.rb"])
    end

  end

end
