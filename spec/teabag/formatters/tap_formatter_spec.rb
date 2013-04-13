require "spec_helper"
require "teabag/formatters/tap_formatter"
require "teabag/result"

describe Teabag::Formatters::TapFormatter do

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#runner" do

    let(:json) { {"start" => "_start_", "total" => 20} }

    it "logs the information" do
      result = Teabag::Result.build_from_json(json)
      subject.should_receive(:log).with("1..20")
      subject.runner(result)
    end

  end

  describe "#spec" do

    describe "passing spec" do

      let(:json) { {"status" => "passed"} }

      it "calls passing_spec" do
        result = Teabag::Result.build_from_json(json)
        subject.should_receive(:passing_spec)
        subject.spec(result)
      end

    end

    describe "pending spec" do

      let(:json) { {"status" => "pending"} }

      it "calls pending_spec" do
        result = Teabag::Result.build_from_json(json)
        subject.should_receive(:pending_spec)
        subject.spec(result)
      end

    end

    describe "failing spec" do

      let(:json) { {"status" => "fail"} }

      it "calls failing_spec" do
        result = Teabag::Result.build_from_json(json)
        subject.should_receive(:failing_spec)
        subject.spec(result)
      end

    end

  end

  describe "#error" do

    it "keeps count" do
      expect(subject.errors.size).to be(0)
      subject.error("foo")
      expect(subject.errors.size).to be(1)
    end

  end

  describe "#passing_spec" do

    let(:json) { {"suite" => "_suite_", "label" => "_label_"} }

    it "logs the information" do
      result = Teabag::Result.build_from_json(json)
      subject.should_receive(:log).with("ok 42 - _suite_ _label_")
      subject.instance_variable_set(:@total, 42)
      subject.instance_variable_set(:@result, result)
      subject.send(:passing_spec)
    end

  end

  describe "#pending_spec" do

    let(:json) { {"suite" => "_suite_", "label" => "_label_"} }

    it "logs the information" do
      result = Teabag::Result.build_from_json(json)
      subject.should_receive(:log).with("ok 42 - [pending] _suite_ _label_")
      subject.instance_variable_set(:@total, 42)
      subject.instance_variable_set(:@result, result)
      subject.send(:pending_spec)
    end

  end

  describe "#failing_spec" do

    let(:json) { {"suite" => "_suite_", "label" => "_label_", "message" => "_message_"} }

    it "logs the information" do
      result = Teabag::Result.build_from_json(json)
      subject.should_receive(:log).with("not ok 42 - _suite_ _label_\n  # FAIL _message_")
      subject.instance_variable_set(:@total, 42)
      subject.instance_variable_set(:@result, result)
      subject.send(:failing_spec)
    end

  end

  describe "#log" do

    it "calls STDOUT.print" do
      STDOUT.should_receive(:print).with("foo\n")
      subject.send(:log, "foo")
    end
  end

end
