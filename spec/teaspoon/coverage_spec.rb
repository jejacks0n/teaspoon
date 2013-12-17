require "spec_helper"
require "teaspoon/coverage"

describe Teaspoon::Coverage do

  subject { Teaspoon::Coverage.new({"foo" => "bar"}) }

  describe "#reports" do

    before do
      Teaspoon.configuration.should_receive(:coverage_reports).and_return(["text", "text-summary", "html"])
      subject.stub(:generate_report) { |i, f| "_#{f}_report_" }
      File.stub(:open)

      @check_coverage = double('check_coverage')
      Teaspoon::CheckCoverage.stub(:new).and_return(@check_coverage)

      path = nil
      Dir.mktmpdir { |p| path = p }
      Dir.stub(:mktmpdir).and_yield(path)
      @output = File.join(path, "coverage.json")
    end

    it "writes the data to a file" do
      file = double('file')
      File.should_receive(:open).with(@output, "w").and_yield(file)
      file.should_receive(:write).with('{"foo":"bar"}')
      @check_coverage.should_receive(:check_coverage)
      subject.reports
    end

    it "collects the results and returns them" do
      subject.should_receive(:generate_report).with(@output, "text")
      subject.should_receive(:generate_report).with(@output, "text-summary")
      subject.should_receive(:generate_report).with(@output, "html")
      @check_coverage.should_receive(:check_coverage)
      expect(subject.reports).to eq("\n_text_report_\n\n_text-summary_report_\n")
    end

    it "executes coverage checks" do
      Teaspoon::CheckCoverage.should_receive(:new).with(@output)
      @check_coverage.should_receive(:check_coverage)
      subject.reports
    end

  end

end
