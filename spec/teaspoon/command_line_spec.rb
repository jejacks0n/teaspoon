require "spec_helper"
require "teaspoon/command_line"
require "teaspoon/console"

module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end
end

describe Teaspoon::CommandLine do

  subject { Teaspoon::CommandLine }

  let(:console) { double(failures?: false) }
  let(:parser) { double(parse!: ["file1", "file2"]) }

  describe "#initialize" do

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

    it "logs a message and exits on abort" do
      STDOUT.should_receive(:print).with("Teaspoon::EnvironmentNotFound\nConsider using -r path/to/teaspoon_env\n")
      Teaspoon::Console.should_receive(:new).and_raise(Teaspoon::EnvironmentNotFound)
      subject.any_instance.should_receive(:abort).and_call_original
      expect { subject.new }.to raise_error SystemExit
    end

  end

  describe "opt_parser" do

    before do
      @log = ""
      STDOUT.stub(:print) { |s| @log << s }
      Teaspoon::Console.stub(:new).and_return(console)
    end

    it "has --help" do
      suppress_warnings { ARGV = ["--help"] }
      expect { subject.new.opt_parser }.to raise_error SystemExit
      expect(@log).to include <<-OUTPUT.strip_heredoc
      Usage: teaspoon [options] [files]

          -r, --require FILE               Require Teaspoon environment file.
          -d, --driver DRIVER              Specify driver:
                                             phantomjs (default)
                                             selenium
              --driver-options OPTIONS     Specify driver-specific options to pass into the driver.
                                             e.g. "--ssl-protocol=any --ssl-certificates-path=/path/to/certs".
                                             Driver options are only supported with phantomjs.
              --driver-timeout SECONDS     Sets the timeout for the driver to wait before exiting.
              --server SERVER              Sets server to use with Rack.
                                             e.g. webrick, thin
              --server-port PORT           Sets the server to use a specific port.
              --server-timeout SECONDS     Sets the timeout that the server must start within.
          -F, --[no-]fail-fast             Abort after the first failing suite.

        **** Filtering ****

          -s, --suite SUITE                Focus to a specific suite.
          -g, --filter FILTER              Filter tests matching a specific filter.

        **** Output ****

          -q, --[no-]suppress-log          Suppress logs coming from console[log/debug/error].
          -c, --[no-]color                 Enable/Disable color output.
          -e, --export [OUTPUT_PATH]       Exports the test suite as the full HTML (requires wget).
          -f, --format FORMATTERS          Specify formatters (comma separated)
                                             dot (default) - dots
                                             documentation - descriptive documentation
                                             clean - like dots but doesn't log re-run commands
                                             json - json formatter (raw teaspoon)
                                             junit - junit compatible formatter
                                             pride - yay rainbows!
                                             snowday - makes you feel warm inside
                                             swayze_or_oprah - quote from either Patrick Swayze or Oprah Winfrey
                                             tap - test anything protocol formatter
                                             tap_y - tap_yaml, format used by tapout
                                             teamcity - teamcity compatible formatter

        **** Coverage ****

          -C, --coverage CONFIG_NAME       Generate coverage reports using a pre-defined coverage configuration.

        **** Utility ****

          -v, --version                    Display the version.
          -h, --help                       You're looking at it.
      OUTPUT
    end

    it "has --version" do
      suppress_warnings { ARGV = ["--version"] }
      expect { subject.new.opt_parser }.to raise_error SystemExit
      expect(@log).to match(/\d+\.\d+\.\d+\n/)
    end

    it "has various other arguments" do
      value_flags = {
        environment: ["require", "_environment_"],
        driver: ["driver", "_driver_"],
        driver_options: ["driver-options", "_driver_options_"],
        driver_timeout: ["driver-timeout", "_driver_timeout_"],
        server: ["server", "_server_"],
        server_port: ["server-port", "_server_port_"],
        server_timeout: ["server-timeout", "_server_timeout_"],
        suite: ["suite", "_suite_"],
        filter: ["filter", "_filter_"],
        export: ["export", "_export_"],
        formatters: ["format", "_foo,bar_"],
        use_coverage: ["coverage", "_coverage_"],
      }

      bool_flags = {
        fail_fast: "fail-fast",
        suppress_log: "suppress-log",
        color: "color",
      }

      value_flags.each do |k, v|
        suppress_warnings { ARGV = ["--#{v[0]}=#{v[1]}"] }
        expect(subject.new.instance_variable_get(:@options)[k]).to eq(v[1])
      end

      bool_flags.each do |k, v|
        suppress_warnings { ARGV = ["--#{v}"] }
        expect(subject.new.instance_variable_get(:@options)[k]).to eq(true)
        suppress_warnings { ARGV = ["--no-#{v}"] }
        expect(subject.new.instance_variable_get(:@options)[k]).to eq(false)
      end
    end

  end

end
