#require "spec_helper"
#require "teaspoon/coverage"
#
#describe Teaspoon::Coverage do
#
#  subject { Teaspoon::Coverage.new({"foo" => "bar"}, "default") }
#
#  describe "#reports" do
#
#    before do
#      Teaspoon.configuration.should_receive(:coverage_reports).and_return(["text", "text-summary", "html"])
#      subject.stub(:generate_report) { |i, f| "_#{f}_report_" }
#      File.stub(:open)
#
#      @check_coverage = double('check_coverage')
#      Teaspoon::CheckCoverage.stub(:new).and_return(@check_coverage)
#
#      path = nil
#      Dir.mktmpdir { |p| path = p }
#      Dir.stub(:mktmpdir).and_yield(path)
#      @output = File.join(path, "coverage.json")
#    end
#
#    it "writes the data to a file" do
#      file = double('file')
#      File.should_receive(:open).with(@output, "w").and_yield(file)
#      file.should_receive(:write).with('{"foo":"bar"}')
#      @check_coverage.should_receive(:check_coverage)
#      subject.reports
#    end
#
#    it "collects the results and returns them" do
#      subject.should_receive(:generate_report).with(@output, "text")
#      subject.should_receive(:generate_report).with(@output, "text-summary")
#      subject.should_receive(:generate_report).with(@output, "html")
#      @check_coverage.should_receive(:check_coverage)
#      expect(subject.reports).to eq("\n_text_report_\n\n_text-summary_report_\n")
#    end
#
#    it "executes coverage checks" do
#      Teaspoon::CheckCoverage.should_receive(:new).with(@output)
#      @check_coverage.should_receive(:check_coverage)
#      subject.reports
#    end
#
#  end
#
#end
#require "spec_helper"
#require "teaspoon/check_coverage"
#
#describe Teaspoon::CheckCoverage do
#
#  before(:each) do
#    path = nil
#    Dir.mktmpdir { |p| path = p }
#    Dir.stub(:mktmpdir).and_yield(path)
#    output = File.join(path, "coverage.json")
#    @subject = Teaspoon::CheckCoverage.new(output)
#  end
#
#  describe "#check_coverage" do
#
#    context "coverage thresholds NOT set" do
#
#      before do
#        Teaspoon.configuration.should_receive(:statements_coverage_threshold).and_return(nil)
#        Teaspoon.configuration.should_receive(:functions_coverage_threshold).and_return(nil)
#        Teaspoon.configuration.should_receive(:branches_coverage_threshold).and_return(nil)
#        Teaspoon.configuration.should_receive(:lines_coverage_threshold).and_return(nil)
#      end
#
#      it "does not check the coverage" do
#        @subject.should_not_receive(:do_check_coverage)
#        @subject.check_coverage
#      end
#
#    end
#
#    context "coverage thresholds set" do
#      before do
#        Teaspoon.configuration.should_receive(:statements_coverage_threshold).and_return(50)
#        Teaspoon.configuration.should_receive(:functions_coverage_threshold).and_return(60)
#        Teaspoon.configuration.should_receive(:branches_coverage_threshold).and_return(70)
#        Teaspoon.configuration.should_receive(:lines_coverage_threshold).and_return(80)
#        @subject.stub(:do_check_coverage)
#      end
#
#      it "checks the coverage" do
#        @subject.should_receive(:do_check_coverage).with("--statements 50 --functions 60 --branches 70 --lines 80")
#        @subject.check_coverage
#      end
#
#    end
#
#  end
#
#end
