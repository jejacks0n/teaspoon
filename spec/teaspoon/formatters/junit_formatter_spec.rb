require "spec_helper"
require "teaspoon/formatters/junit_formatter"
require "teaspoon/result"

describe Teaspoon::Formatters::JunitFormatter do

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#runner" do

    let(:json) { {"start" => "_start_", "total" => 20} }

    it "logs the information" do
      result = Teaspoon::Result.build_from_json(json)
      subject.should_receive(:log).with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
      subject.should_receive(:log).with("<testsuites name=\"jasmine\"><testsuite name=\"\" tests=\"20\">")
      subject.runner(result)
    end

  end

  describe "#spec" do

    describe "passing spec" do

      let(:json) { {"status" => "passed", "suite" => "My Suite", "label" => "My Label"} }

      it "calls passing_spec" do
        result = Teaspoon::Result.build_from_json(json)
        subject.spec(result)

        @log.should include "<testcase classname=\"My Suite\" name=\"My Label\"></testcase>"
      end

    end

    describe "pending spec" do

      let(:json) { {"status" => "pending", "suite" => "My Suite", "label" => "My Label"} }

      it "calls pending_spec" do
        result = Teaspoon::Result.build_from_json(json)
        subject.spec(result)
        @log.should include "<testcase classname=\"My Suite\" name=\"My Label\"><skipped /></testcase>"
      end

    end

    describe "failing spec" do

      let(:json) { {"status" => "fail", "suite" => "My Suite", "label" => "My Label", "message" => "Error, oh no"} }

      it "calls failing_spec" do
        result = Teaspoon::Result.build_from_json(json)
        subject.spec(result)
        @log.should include "<testcase classname=\"My Suite\" name=\"My Label\">
<failure type=\"AssertionFailed\">Error, oh no</failure>
</testcase>"
      end

    end

  end
  describe "#result" do

    it "ends the suite" do
      subject.result('result')

      @log.should include "</testsuite></testsuites>"
    end

  end

end
