require "spec_helper"
require "teaspoon/check_coverage"

describe Teaspoon::CheckCoverage do

  before(:each) do
    path = nil
    Dir.mktmpdir { |p| path = p }
    Dir.stub(:mktmpdir).and_yield(path)
    output = File.join(path, "coverage.json")
    @subject = Teaspoon::CheckCoverage.new(output)
  end

  describe "#check_coverage" do

    context "coverage thresholds NOT set" do

      before do
        Teaspoon.configuration.should_receive(:statements_coverage_threshold).and_return(nil)
        Teaspoon.configuration.should_receive(:functions_coverage_threshold).and_return(nil)
        Teaspoon.configuration.should_receive(:branches_coverage_threshold).and_return(nil)
        Teaspoon.configuration.should_receive(:lines_coverage_threshold).and_return(nil)
      end

      it "does not check the coverage" do
        @subject.should_not_receive(:do_check_coverage)
        @subject.check_coverage
      end

    end

    context "coverage thresholds set" do
      before do
        Teaspoon.configuration.should_receive(:statements_coverage_threshold).and_return(50)
        Teaspoon.configuration.should_receive(:functions_coverage_threshold).and_return(60)
        Teaspoon.configuration.should_receive(:branches_coverage_threshold).and_return(70)
        Teaspoon.configuration.should_receive(:lines_coverage_threshold).and_return(80)
        @subject.stub(:do_check_coverage)
     end

      it "checks the coverage" do
        @subject.should_receive(:do_check_coverage).with("--statements 50 --functions 60 --branches 70 --lines 80")
        @subject.check_coverage
      end

    end

  end

end
