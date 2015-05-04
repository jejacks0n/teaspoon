require "spec_helper"
require_relative("../../../lib/generators/teaspoon/install/install_generator")

describe Teaspoon::Generators::InstallGenerator do
  subject { described_class.new([], options) }
  let(:options) { {} }
  before do
    allow(subject).to receive(:readme)
    allow(subject).to receive(:say_status)
    allow(subject).to receive(:template)
    allow(subject).to receive(:empty_directory)
    allow(subject).to receive(:copy_file)
  end

  it "has a useful description" do
    expect(described_class.desc).to eq("Installs the Teaspoon initializer into your application.")
  end

  it "has useful help" do
    help = []
    shell = double(say: nil, print_table: nil)
    allow(shell).to receive(:say) { |msg| help << msg }
    allow(shell).to receive(:print_table) { |msg| help << msg }

    described_class.help(shell)
    expect(help.join("\n").gsub(/\n+/, "\n")).to include(<<-HELP.strip_heredoc)
      Usage:
        rails generate teaspoon:install [options]
      Options:
      -t, [--framework=FRAMEWORK]
      # Specify which test framework to use (Available: jasmine, mocha, qunit)
      # Default: jasmine
      -v, [--version=VERSION]
      # Specify the framework version to use (Depends on the framework)
      -c, [--coffee], [--no-coffee]
      # Generate a CoffeeScript spec helper instead of Javascript
      -d, [--documentation], [--no-documentation]
      # Install the teaspoon_env.rb with comment documentation
      # Default: true
      -p, [--partials], [--no-partials]
      # Copy the boot and body partials
    HELP
  end

  describe "#verify_framework_and_version" do
    it "finds the framework" do
      expect(subject.verify_framework_and_version).to eq(Teaspoon::Jasmine::Framework)
    end

    it "exits with some help text when there's no frameworks" do
      expect(Teaspoon::Framework).to receive(:fetch).and_raise
      expect(Teaspoon::Framework).to receive(:available).and_return({})
      expect(subject).to receive(:readme).with("MISSING_FRAMEWORK")
      expect { subject.verify_framework_and_version }.to raise_error(SystemExit)
    end

    describe "when the requested framework is not available" do
      let(:options) { { framework: "unknown" } }

      it "exits with a message" do
        message = ""
        expect(subject).to receive(:say_status).with(kind_of(String), nil, :red) { |msg| message = msg }
        expect { subject.verify_framework_and_version }.to raise_error(SystemExit)
        expect(message).to include("Unknown framework: unknown")
        expect(message).to match(/Available: jasmine: versions\[(\d+\.\d+\.\d+,?\s?)+\]/)
      end
    end

    describe "when version is specified" do
      let(:options) { { version: "6.6.6" } }

      it "exits with a message if the requested framework version is not available" do
        message = ""
        expect(subject).to receive(:say_status).with(kind_of(String), nil, :red) { |msg| message = msg }
        expect { subject.verify_framework_and_version }.to raise_error(SystemExit)
        expect(message).to include("Unknown framework: jasmine[6.6.6]")
        expect(message).to match(/Available: jasmine: versions\[(\d+\.\d+\.\d+,?\s?)+\]/)
      end
    end
  end

  describe "#copy_environment" do
    it "installs the env with documentation by default" do
      expect(subject).to receive(:template).with("env_comments.rb.tt", "spec/teaspoon_env.rb")
      subject.copy_environment
    end

    describe "without documentation" do
      let(:options) { { documentation: false } }

      it "installs the env without documentation" do
        expect(subject).to receive(:template).with("env.rb.tt", "spec/teaspoon_env.rb")
        subject.copy_environment
      end
    end
  end

  describe "#create_structure" do
    it "creates the basic directory structure" do
      expect(subject).to receive(:empty_directory).once.with("spec/javascripts/support")
      expect(subject).to receive(:empty_directory).once.with("spec/javascripts/fixtures")
      subject.create_structure
    end
  end

  describe "#install_framework_files" do
    it "calls through to the frameworks install callback to allow it to do what it wants" do
      called = false
      expect(Teaspoon::Jasmine::Framework).to receive(:install_callback).
        and_return(proc { called = true })
      subject.install_framework_files
      expect(called).to be_truthy
    end
  end

  describe "#copy_partials" do
    it "doesn't install view partials by default" do
      expect(subject).to_not receive(:copy_file)
      subject.copy_partials
    end

    describe "when partials are desired" do
      let(:options) { { partials: true } }

      it "installs view partials" do
        expect(subject).to receive(:copy_file).once.with("_boot.html.erb", "spec/javascripts/fixtures/_boot.html.erb")
        expect(subject).to receive(:copy_file).once.with("_body.html.erb", "spec/javascripts/fixtures/_body.html.erb")
        subject.copy_partials
      end
    end
  end

  describe "#display_post_install" do
    it "displays the post install message" do
      expect(subject).to receive(:readme).with("POST_INSTALL")
      subject.display_post_install
    end
  end
end
