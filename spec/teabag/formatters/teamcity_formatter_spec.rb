require "spec_helper"
require "teabag/formatters/teamcity_formatter"
require "teabag/result"

describe Teabag::Formatters::TeamcityFormatter do

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#runner" do

    let(:json) { {"start" => "_start_", "total" => 20} }

    it "logs the information" do
      result = Teabag::Result.build_from_json(json)
      subject.should_receive(:log).with("##teamcity[testSuiteStarted name='Jasmine']")
      subject.runner(result)
    end

  end

  describe "#spec" do

    describe "passing spec" do

      let(:json) { {"status" => "passed", "suite" => "My Suite", "label" => "My Label"} }

      it "calls passing_spec" do
        result = Teabag::Result.build_from_json(json)
        subject.spec(result)

        @log.should include "##teamcity[testStarted name='My Suite My Label' captureStandardOutput='false']
##teamcity[testFinished name='My Suite My Label']"
      end

    end

    describe "pending spec" do

      let(:json) { {"status" => "pending", "suite" => "My Suite", "label" => "My Label"} }

      it "calls pending_spec" do
        result = Teabag::Result.build_from_json(json)
        subject.spec(result)
        @log.should include "##teamcity[testStarted name='My Suite My Label' captureStandardOutput='false']
##teamcity[testFinished name='My Suite My Label']"
      end

    end

    describe "failing spec" do

      let(:json) { {"status" => "fail", "suite" => "My Suite", "label" => "My Label", "message" => "Error, oh no"} }

      it "calls failing_spec" do
        result = Teabag::Result.build_from_json(json)
        subject.spec(result)
        @log.should include "##teamcity[testStarted name='My Suite My Label' captureStandardOutput='false']
##teamcity[testFailed name='My Suite My Label' message='Error, oh no']
##teamcity[testFinished name='My Suite My Label']"
      end

    end

  end

  describe "#error" do

    let(:json) { {"status" => "error", "message" => "Error, oh no", "trace" => [{"file" => "myfile.js", "line" => "33"}] } }

    it "logs error" do
      error = Teabag::Result.build_from_json(json)
      subject.error(error)
      @log.should include "##teamcity[message text='Error, oh no' errorDetails='myfile.js:33' status='ERROR']"
    end

  end

  describe "#result" do

    it "ends the suite" do
      subject.result('result')

      @log.should include "##teamcity[testSuiteFinished name='Jasmine']"
    end

  end

end
