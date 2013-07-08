require "spec_helper"
require "teaspoon/formatters/base_formatter"
require "teaspoon/result"

describe Teaspoon::Formatters::BaseFormatter do

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#result" do

    it "calls log_coverage" do
      subject.should_receive(:log_coverage).with("_coverage_")
      subject.result("coverage" => "_coverage_")
    end

  end

  describe "#log_coverage" do

    it "logs the coverage information" do
      double = double(reports: nil)
      Teaspoon::Coverage.should_receive(:new).with("_data_").and_return(double)
      double.should_receive(:reports).and_return("_reports_")
      STDOUT.should_receive(:print).with("_reports_")
      subject.send(:log_coverage, "_data_")
    end

    it "doesn't log if there's no data" do
      Teaspoon::Coverage.should_not_receive(:new)
      subject.send(:log_coverage, {})
    end

    it "doesn't log when suppressing logs" do
      subject.should_receive(:suppress_logs?).and_return(true)
      Teaspoon::Coverage.should_not_receive(:new)
      subject.send(:log_coverage, "_data_")
    end

  end

end
