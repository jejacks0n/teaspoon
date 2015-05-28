require "spec_helper"
require "teaspoon/environment"

describe Teaspoon::Environment do
  subject { described_class }

  before do
    @orig_teaspoon_env = ENV["TEASPOON_ENV"]
    ENV["TEASPOON_ENV"] = nil
  end

  after do
    ENV["TEASPOON_ENV"] = @orig_teaspoon_env
  end

  describe ".load" do
    before do
      allow(subject).to receive(:load_rails)
    end

    it "calls require_environment" do
      expect(subject).to receive(:load_rails)
      expect(subject).to receive(:rails_loaded?).and_return(true)
      described_class.load
    end

    it "falls back to loading the teaspoon environment" do
      allow(subject).to receive(:load_rails).and_call_original
      allow(File).to receive(:exists?).and_return(false)
      expect(subject).to receive(:require_environment)
      described_class.load
    end

    it "aborts if Rails can't be found" do
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
    end

    after do
      Teaspoon.configured = true
    end

    describe "when loading with an override" do
      let(:expanded) { File.expand_path("_override_", Dir.pwd) }

      before do
        allow(subject).to receive(:require_env).and_call_original
        allow(::Kernel).to receive(:load).with(expanded)
      end

      it "allows passing an override" do
        allow(Teaspoon::Environment).to receive(:find_env).and_return(expanded)
        expect(::Kernel).to receive(:load).with(expanded)

        subject.require_environment("_override_")
      end

      it "sets the TEASPOON_ENV so that the web app can access it when run on the CLI" do
        allow(File).to receive(:exists?).and_return(true)
        subject.require_environment("_override_")

        expect(ENV["TEASPOON_ENV"]).to eq(expanded)
      end
    end

    describe "when loading from defaults" do
      it "looks for the standard files" do
        expect(File).to receive(:exists?).with(File.expand_path("spec/teaspoon_env.rb", Dir.pwd)).and_return(false)
        expect(File).to receive(:exists?).with(File.expand_path("test/teaspoon_env.rb", Dir.pwd)).and_return(false)
        expect(File).to receive(:exists?).with(File.expand_path("teaspoon_env.rb", Dir.pwd)).and_return(true)
        expect(subject).to receive(:require_env).with(File.expand_path("teaspoon_env.rb", Dir.pwd))
        subject.require_environment
      end

      it "short circuits when it finds a file" do
        expect(File).to receive(:exists?).with(File.expand_path("spec/teaspoon_env.rb", Dir.pwd)).and_return(true)
        expect(File).not_to receive(:exists?).with(File.expand_path("test/teaspoon_env.rb", Dir.pwd))
        expect(subject).to receive(:require_env).with(File.expand_path("spec/teaspoon_env.rb", Dir.pwd))
        subject.require_environment
      end

      it "raises if no env file was found" do
        expect { subject.require_environment }.to raise_error(
          Teaspoon::EnvironmentNotFound,
          "Unable to locate environment; searched in [spec/teaspoon_env.rb, test/teaspoon_env.rb, teaspoon_env.rb]. "\
          "Have you run the installer?"
        )
      end
    end
  end

  describe ".check_env!" do
    it "does nothing if an env file exists" do
      allow(File).to receive(:exists?).and_return(true)

      expect { subject.check_env! }.not_to raise_error
    end

    it "does nothing if an override env file exists" do
      expect(File).to receive(:exists?).with(/_override_/).and_return(true)

      expect { subject.check_env!("_override_") }.not_to raise_error
    end

    it "raises if no env file was found" do
      allow(File).to receive(:exists?).and_return(false)

      expect { subject.check_env! }.to raise_error(
        Teaspoon::EnvironmentNotFound,
        "Unable to locate environment; searched in [spec/teaspoon_env.rb, test/teaspoon_env.rb, teaspoon_env.rb]. "\
        "Have you run the installer?"
      )
    end

    it "raises if no override env file was found" do
      expect(File).to receive(:exists?).with(/_override_/).and_return(false)

      expect { subject.check_env!("_override_") }.to raise_error(
        Teaspoon::EnvironmentNotFound,
        "Unable to locate environment; searched in [_override_]. Have you run the installer?"
      )
    end
  end

  describe ".rails_loaded?" do
    it "returns a boolean based on if Rails is defined" do
      expect(subject.send(:rails_loaded?)).to eql(true)
    end
  end
end
