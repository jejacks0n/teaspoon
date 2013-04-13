require "spec_helper"
require "teabag/formatters/base_formatter"
require "teabag/result"

describe Teabag::Formatters::BaseFormatter do

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
      mock = mock(reports: nil)
      Teabag::Coverage.should_receive(:new).with("_data_").and_return(mock)
      mock.should_receive(:reports).and_return("_reports_")
      STDOUT.should_receive(:print).with("_reports_")
      subject.send(:log_coverage, "_data_")
    end

    it "doesn't log if there's no data" do
      Teabag::Coverage.should_not_receive(:new)
      subject.send(:log_coverage, {})
    end

    it "doesn't log when suppressing logs" do
      subject.should_receive(:suppress_logs?).and_return(true)
      Teabag::Coverage.should_not_receive(:new)
      subject.send(:log_coverage, "_data_")
    end

  end

end
