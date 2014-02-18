require "spec_helper"
require "teaspoon/coverage"

describe Teaspoon::Coverage do

  subject { Teaspoon::Coverage.new("_suite_", "default", data) }
  let(:data) { {foo: "bar"} }
  let(:config) { double }

  before do
    Teaspoon::Instrumentation.stub(:executable).and_return("/path/to/executable")
    subject.stub(:`).and_return("")
    subject.stub(:input_path).and_yield("/temp_path/coverage.json")
    subject.instance_variable_set(:@config, config)
  end

  describe "#initialize" do

    it "sets @suite_name" do
      expect(subject.instance_variable_get(:@suite_name)).to eq("_suite_")
    end

    it "finds the executable from instrumentation" do
      expect(subject.instance_variable_get(:@executable)).to eq("/path/to/executable")
    end

    it "gets the coverage configuration" do
      Teaspoon::Coverage.any_instance.should_receive(:coverage_configuration).with("default")
      subject = Teaspoon::Coverage.new("_suite_", :default, data)
    end

  end

  describe "#generate_reports" do

    let(:config) { double(reports: ["html", "text", "text-summary"], output_path: "output/path") }

    it "generates reports using istanbul and passes them to the block provided" do
      `(exit 0)`
      html_report = "/path/to/executable report html /temp_path/coverage.json --dir output/path/_suite_ 2>&1"
      text1_report = "/path/to/executable report text /temp_path/coverage.json --dir output/path/_suite_ 2>&1"
      text2_report = "/path/to/executable report text-summary /temp_path/coverage.json --dir output/path/_suite_ 2>&1"
      subject.should_receive(:`).with(html_report).and_return("_html_report_")
      subject.should_receive(:`).with(text1_report).and_return("_text1_report_")
      subject.should_receive(:`).with(text2_report).and_return("_text2_report_")
      subject.generate_reports { |r| @result = r }
      expect(@result).to eq("_text1_report_\n\n_text2_report_")
    end

    it "raises a Teaspoon::DependencyFailure if the command doesn't exit cleanly" do
      `(exit 1)`
      expect { subject.generate_reports }.to raise_error Teaspoon::DependencyFailure, "Could not generate coverage report for html"
    end

  end

  describe "#check_thresholds" do

    let(:config) { double(statements: 42, functions: 66.6, branches: 0, lines: 100) }

    it "does nothing if there are no threshold checks to make" do
      subject.should_receive(:threshold_args).and_return(nil)
      subject.should_not_receive(:input_path)
      subject.check_thresholds {}
    end

    it "checks the coverage using istanbul and passes them to the block provided" do
      `(exit 1)`
      check_coverage = "/path/to/executable check-coverage --statements=42 --functions=66.6 --branches=0 --lines=100 /temp_path/coverage.json 2>&1"
      subject.should_receive(:`).with(check_coverage).and_return("some mumbo jumbo\nERROR: _failure1_\nmore garbage\nERROR: _failure2_")
      subject.check_thresholds { |r| @result = r }
      expect(@result).to eq("_failure1_\n_failure2_")
    end

    it "doesn't call the callback if the exit status is 0" do
      `(exit 0)`
      subject.should_receive(:`).and_return("ERROR: _failure1_")
      subject.check_thresholds { |r| @called = true }
      expect(@called).to be_false
    end

  end

  describe "integration" do

    let(:config) { double(reports: ["text", "text-summary"], output_path: "output/path") }

    before do
      Teaspoon::Instrumentation.instance_variable_set(:@executable, nil)
      Teaspoon::Instrumentation.instance_variable_set(:@executable_checked, nil)
      Teaspoon::Instrumentation.should_receive(:executable).and_call_original
      subject.should_receive(:input_path).and_call_original
      subject.should_receive(:`).and_call_original

      executable = Teaspoon::Instrumentation.executable
      pending('needs istanbul to be installed') unless executable
      subject.instance_variable_set(:@executable, executable)
      subject.instance_variable_set(:@data, JSON.parse(IO.read(Teaspoon::Engine.root.join('spec/fixtures/coverage.json'))))
    end

    it "generates coverage reports" do
      subject.generate_reports { |r| @report = r }
      expect(@report).to eq <<-RESULT.strip_heredoc + "\n"
        -------------------------+-----------+-----------+-----------+-----------+
        File                     |   % Stmts |% Branches |   % Funcs |   % Lines |
        -------------------------+-----------+-----------+-----------+-----------+
           integration/          |     90.91 |       100 |        75 |     90.91 |
              integration.coffee |        75 |       100 |        50 |        75 |
              spec_helper.coffee |       100 |       100 |       100 |       100 |
        -------------------------+-----------+-----------+-----------+-----------+
        All files                |     90.91 |       100 |        75 |     90.91 |
        -------------------------+-----------+-----------+-----------+-----------+
      RESULT
    end

  end

end
