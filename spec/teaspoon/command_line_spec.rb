require "spec_helper"
require "teaspoon/command_line"
require "teaspoon/console"

describe Teaspoon::CommandLine do
  subject { described_class }

  let(:console) { double(failures?: false) }
  let(:parser) { double(parse!: ["file1", "file2"]) }

  describe "#initialize" do
    before do
      allow(Teaspoon::Console).to receive(:new).and_return(console)
      allow_any_instance_of(subject).to receive(:abort)
      allow_any_instance_of(subject).to receive(:opt_parser).and_return(parser)
    end

    it "assigns @options and adds the files that were parsed out" do
      expect(subject.new.instance_variable_get(:@options)).to eq(files: ["file1", "file2"])
    end

    it "aborts with a message on Teaspoon::EnvironmentNotFound" do
      expect(Teaspoon::Console).to receive(:new).
        and_raise(Teaspoon::EnvironmentNotFound.new(searched: "path1, path2"))
      expect(Teaspoon).to receive(:abort).with(
        "Unable to locate environment; searched in [path1, path2]. Have you run the installer? "\
        "Consider using --require=path/to/teaspoon_env.rb"
      )
      subject.new
    end

    it "executes using Teaspoon::Console" do
      expect(Teaspoon::Console).to receive(:new).with(files: ["file1", "file2"])
      expect(console).to receive(:failures?)
      subject.new
    end

    it "aborts if Teaspoon::Console fails" do
      expect(Teaspoon).to receive(:abort)
      expect(console).to receive(:failures?).and_return(true)
      subject.new
    end
  end

  describe "#opt_parser" do
    before do
      @log = ""
      allow(STDOUT).to receive(:print) { |s| @log << s }
      allow(Teaspoon::Console).to receive(:new).and_return(console)
    end

    it "has --help" do
      suppress_warnings { ARGV = ["--help"] }
      expect { subject.new.opt_parser }.to raise_error(SystemExit)
      expect(@log).to include <<-OUTPUT.strip_heredoc
      Usage: teaspoon [options] [files]

          -r, --require FILE               Require Teaspoon environment file.
          -d, --driver DRIVER              Specify driver:
                                             phantomjs (default)
                                             selenium
                                             capybara_webkit
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
                                           #{subject.new.send(:formatter_details).join("\n" + (' ' * 43))}

        **** Coverage ****

          -C, --coverage CONFIG_NAME       Generate coverage reports using a pre-defined coverage configuration.

        **** Utility ****

          -v, --version                    Display the version.
          -h, --help                       You're looking at it.
      OUTPUT
    end

    it "has --version" do
      suppress_warnings { ARGV = ["--version"] }
      expect { subject.new.opt_parser }.to raise_error(SystemExit)
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
