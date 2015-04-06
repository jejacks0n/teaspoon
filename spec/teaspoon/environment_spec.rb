require "spec_helper"
require "teaspoon/environment"

describe Teaspoon::Environment do
  subject { described_class }

  describe ".load" do
    it "calls require_environment" do
      expect(subject).to receive(:require_environment)
      expect(subject).to receive(:rails_loaded?).and_return(true)
      described_class.load
    end

    it "aborts if Rails can't be found" do
      expect(subject).to receive(:require_environment)
      expect(subject).to receive(:rails_loaded?).and_return(false)
      expect(Teaspoon).to receive(:abort).with("Rails environment not found.", 1)
      described_class.load
    end

    it "configures teaspoon from options if the environment is ready" do
      expect(subject).to receive(:rails_loaded?).and_return(true)
      expect(Teaspoon.configuration).to receive(:override_from_options).with(foo: "bar")
      described_class.load(foo: "bar")
    end
  end

  describe ".require_environment" do
    before do
      allow(File).to receive(:exists?)
      allow(subject).to receive(:require_env)
      Teaspoon.configured = false
      @orig_teaspoon_env = ENV["TEASPOON_ENV"]
      ENV["TEASPOON_ENV"] = nil
    end

    after do
      Teaspoon.configured = true
      ENV["TEASPOON_ENV"] = @orig_teaspoon_env
    end

    describe "when loading with an override" do
      before do
        expect(subject).to receive(:require_env).and_call_original
      end

      it "allows passing an override" do
        expanded = File.expand_path("_override_", Dir.pwd)
        expect(::Kernel).to receive(:load).with(expanded)
        subject.require_environment("_override_")
      end

      it "sets the TEASPOON_ENV" do
        expanded = File.expand_path("../../_override_file_", Dir.pwd)
        expect(::Kernel).to receive(:load).with(expanded)
        subject.require_environment("../../_override_file_")
        expect(ENV["TEASPOON_ENV"]).to eq(expanded)
      end
    end

    describe "when loading from defaults" do
      it "looks for the standard files" do
        expect(File).to receive(:exists?).with(File.expand_path("spec/teaspoon_env.rb", Dir.pwd)).and_return(true)
        expect(subject).to receive(:require_env).with(File.expand_path("spec/teaspoon_env.rb", Dir.pwd))
        subject.require_environment

        expect(File).to receive(:exists?).with(File.expand_path("spec/teaspoon_env.rb", Dir.pwd)).and_return(false)
        expect(File).to receive(:exists?).with(File.expand_path("test/teaspoon_env.rb", Dir.pwd)).and_return(true)
        expect(subject).to receive(:require_env).with(File.expand_path("test/teaspoon_env.rb", Dir.pwd))
        subject.require_environment

        expect(File).to receive(:exists?).with(File.expand_path("spec/teaspoon_env.rb", Dir.pwd)).and_return(false)
        expect(File).to receive(:exists?).with(File.expand_path("test/teaspoon_env.rb", Dir.pwd)).and_return(false)
        expect(File).to receive(:exists?).with(File.expand_path("teaspoon_env.rb", Dir.pwd)).and_return(true)
        expect(subject).to receive(:require_env).with(File.expand_path("teaspoon_env.rb", Dir.pwd))
        subject.require_environment
      end

      it "raises if no env file was found" do
        expect { subject.require_environment }.to raise_error(
          Teaspoon::EnvironmentNotFound,
          "Unable to locate environment; searched in [spec/teaspoon_env.rb, test/teaspoon_env.rb, teaspoon_env.rb]."
        )
      end
    end
  end

  describe ".standard_environments" do
    it "returns an array" do
      expect(subject.standard_environments).to eql(["spec/teaspoon_env.rb", "test/teaspoon_env.rb", "teaspoon_env.rb"])
    end
  end

  describe ".rails_loaded?" do
    it "returns a boolean based on if Rails is defined" do
      expect(subject.send(:rails_loaded?)).to eql(true)
    end
  end
end
