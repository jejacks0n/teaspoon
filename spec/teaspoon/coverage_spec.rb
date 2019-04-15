require "spec_helper"
require "teaspoon/coverage"

describe Teaspoon::Coverage do
  subject { described_class.new("_suite_", data) }
  let(:data) { { foo: "bar" } }
  let(:config) { double }

  let(:exit_status_0) { OpenStruct.new exitstatus: 0 }
  let(:exit_status_1) { OpenStruct.new exitstatus: 1 }

  before do
    allow(Teaspoon::Instrumentation).to receive(:executable).and_return("/path/to/executable")
    allow(Teaspoon.configuration).to receive(:use_coverage).and_return(true)
    allow(subject).to receive(:`).and_return("")
    allow(subject).to receive(:input_path).and_yield("/temp_path/coverage.json")
    subject.instance_variable_set(:@config, config)
  end

  describe ".configuration" do
    it "defaults to the configuration defined in Teaspoon.configuration.use_coverage" do
      expect(Teaspoon.configuration.coverage_configs).to receive(:[]).with("default").and_return(instance: double)

      described_class.configuration
    end

    it "allows true in place of :default" do
      expect(Teaspoon.configuration.coverage_configs).to receive(:[]).with("default").and_return(instance: double)

      described_class.configuration(true)
    end

    it "raises an exception if the coverage config can't be found" do
      expect { described_class.configuration(:foo) }.to raise_error(
        Teaspoon::UnknownCoverage,
        "Unknown coverage configuration: expected \"foo\" to be a configured coverage."
      )
    end
  end

  describe "#initialize" do
    it "sets @suite_name" do
      expect(subject.instance_variable_get(:@suite_name)).to eq("_suite_")
    end

    it "finds the executable from instrumentation" do
      expect(subject.instance_variable_get(:@executable)).to eq("/path/to/executable")
    end

    it "raises an exception without data" do
      expect { described_class.new("_suite_", nil) }.to raise_error(
        Teaspoon::CoverageResultsNotFoundError,
        "You requested coverage reports, but no results were found. Are all files being ignored in your coverage config? If you have expand_assets set to false, you will need to remove spec_helper from the ignore list."
      )
    end
  end

  describe "#generate_reports" do
    let(:config) { double(reports: ["html", "text", "text-summary"], output_path: "output/path") }

    it "generates reports using istanbul and passes them to the block provided" do
      stub_exit_code(ExitCodes::SUCCESS)
      base_report  = %w[/path/to/executable report --include=/temp_path/coverage.json --dir\ output/path/_suite_]
      html_report  = base_report + %w[html]
      text1_report = base_report + %w[text]
      text2_report = base_report + %w[text-summary]
      expect(Open3).to receive(:capture2e).with(*html_report). and_return(["_html_report_",  exit_status_0])
      expect(Open3).to receive(:capture2e).with(*text1_report).and_return(["_text1_report_", exit_status_0])
      expect(Open3).to receive(:capture2e).with(*text2_report).and_return(["_text2_report_", exit_status_0])
      subject.generate_reports { |r| @result = r }
      expect(@result).to eq("_text1_report_\n\n_text2_report_")
    end

    it "raises an exception if the command doesn't exit cleanly" do
      stub_exit_code(ExitCodes::EXCEPTION)
      allow(Open3).to receive(:capture2e).and_return(["Results could not be generated.", exit_status_1])

      expect { subject.generate_reports }.to raise_error(
        Teaspoon::DependencyError,
        "Unable to generate html coverage report:\nResults could not be generated."
      )
    end
  end

  describe "#check_thresholds" do
    let(:config) { double(statements: 42, functions: 66.6, branches: 0, lines: 100) }

    it "does nothing if there are no threshold checks to make" do
      expect(subject).to receive(:threshold_args).and_return(nil)
      expect(subject).to_not receive(:input_path)
      subject.check_thresholds { }
    end

    it "checks the coverage using istanbul and passes them to the block provided" do
      stub_exit_code(ExitCodes::EXCEPTION)
      opts = %w[--statements=42 --functions=66.6 --branches=0 --lines=100]
      args = ["/path/to/executable", "check-coverage", *opts, "/temp_path/coverage.json"]
      expect(Open3).to receive(:capture2e).with(*args).
        and_return(["some mumbo jumbo\nERROR: _failure1_\nmore garbage\nERROR: _failure2_", exit_status_1])
      subject.check_thresholds { |r| @result = r }
      expect(@result).to eq("_failure1_\n_failure2_")
    end

    it "doesn't call the callback if the exit status is 0" do
      stub_exit_code(ExitCodes::SUCCESS)
      expect(Open3).to receive(:capture2e).and_return(["ERROR: _failure1_", exit_status_0])
      subject.check_thresholds { @called = true }
      expect(@called).to be_falsey
    end
  end

  describe "integration" do
    let(:config) { double(reports: ["text", "text-summary"], output_path: "output/path") }
    let(:coverage) { JSON.parse(IO.read(Teaspoon::Engine.root.join("spec/fixtures/coverage.json"))) }
    let(:executable) { Teaspoon::Instrumentation.executable }

    before do
      Teaspoon::Instrumentation.instance_variable_set(:@executable, nil)
      Teaspoon::Instrumentation.instance_variable_set(:@executable_checked, nil)
      expect(Teaspoon::Instrumentation).to receive(:executable).and_call_original
      expect(subject).to receive(:input_path).and_call_original
      expect(Open3).to receive(:capture2e).twice.and_call_original

      pending("needs istanbul to be installed") unless executable
      subject.instance_variable_set(:@executable, executable)
      subject.instance_variable_set(:@data, coverage)
    end

    it "generates coverage reports" do
      subject.generate_reports { |r| @report = r }
      expect(@report).to eq <<-RESULT.strip_heredoc.chomp
        ---------------------|----------|----------|----------|----------|----------------|
        File                 |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
        ---------------------|----------|----------|----------|----------|----------------|
         integration/        |    90.91 |      100 |       75 |    90.91 |                |
          integration.coffee |       75 |      100 |       50 |       75 |              5 |
          spec_helper.coffee |      100 |      100 |      100 |      100 |                |
        ---------------------|----------|----------|----------|----------|----------------|
        All files            |    90.91 |      100 |       75 |    90.91 |                |
        ---------------------|----------|----------|----------|----------|----------------|

        =============================== Coverage summary ===============================
        Statements   : 90.91% ( 10/11 )
        Branches     : 100% ( 0/0 )
        Functions    : 75% ( 3/4 )
        Lines        : 90.91% ( 10/11 )
        ================================================================================
      RESULT
    end
  end
end
