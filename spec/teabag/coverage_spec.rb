require "spec_helper"
require "teabag/coverage"

describe Teabag::Coverage do

  subject { Teabag::Coverage.new({"foo" => "bar"}) }

  describe "#reports" do

    before do
      Teabag.configuration.should_receive(:coverage_reports).and_return(["text", "text-summary", "html"])
      subject.stub(:generate_report) { |i, f| "_#{f}_report_" }
      File.stub(:write)

      path = nil
      Dir.mktmpdir { |p| path = p }
      Dir.stub(:mktmpdir).and_yield(path)
      @output = File.join(path, "coverage.json")
    end

    it "writes the data to a file" do
      File.should_receive(:write).with(@output, '{"foo":"bar"}')
      subject.reports
    end

    it "collects the results and returns them" do
      subject.should_receive(:generate_report).with(@output, "text")
      subject.should_receive(:generate_report).with(@output, "text-summary")
      subject.should_receive(:generate_report).with(@output, "html")
      expect(subject.reports).to eq("\n_text_report_\n\n_text-summary_report_\n")
    end

  end

end
