require "spec_helper"
require "teabag/formatters/tap_y_formatter"
require "teabag/result"

describe Teabag::Formatters::TapYFormatter do

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#runner" do

    let(:json) { {"start" => "_start_", "total" => 20} }

    it "logs the information" do
      result = Teabag::Result.build_from_json(json)
      subject.should_receive(:log).with(
        "type"  => "suite",
        "start" => "_start_",
        "count" => 20,
        "seed"  => 0,
        "rev"   => 4
      )
      subject.runner(result)
    end

  end

  describe "#suite" do

    let(:json) { {"label" => "_label_", "level" => 1} }

    it "logs the information" do
      result = Teabag::Result.build_from_json(json)
      subject.should_receive(:log).with(
        "type"  => "case",
        "label" => "_label_",
        "level" => 1
      )
      subject.suite(result)
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

  describe "#result" do

    let(:json) { {"elapsed" => "0.00666"} }

    it "logs the information" do
      result = Teabag::Result.build_from_json(json)
      subject.should_receive(:log).with(
        "type"  => "final",
        "time"  => "0.00666",
        "counts" => {
          "total" => 0,
          "pass"  => 0,
          "fail"  => 0,
          "error" => 0,
          "omit"  => 0,
          "todo"  => 0
        }
      )
      subject.result(result)
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

    let(:json) { {"label" => "_label_"} }

    it "logs the information" do
      result = Teabag::Result.build_from_json(json)
      subject.should_receive(:log).with(
        "type"   => "test",
        "status" => "pass",
        "label"  => "_label_"
      )
      subject.instance_variable_set(:@result, result)
      subject.send(:passing_spec)
    end

  end

  describe "#pending_spec" do

    let(:json) { {"label" => "_label_", "message" => "_message_"} }

    it "logs the information" do
      result = Teabag::Result.build_from_json(json)
      subject.should_receive(:log).with(
        "type"   => "test",
        "status" => "pending",
        "label"  => "_label_",
        "exception" => {
          "message"   => "_message_"
        }
      )
      subject.instance_variable_set(:@result, result)
      subject.send(:pending_spec)
    end

  end

  describe "#failing_spec" do

    let(:json) { {"label" => "_label_", "link" => "_link_", "message" => "_message_"} }

    it "logs the information" do
      result = Teabag::Result.build_from_json(json)
      subject.should_receive(:log).with(
        "type"   => "test",
        "status" => "fail",
        "label"  => "_label_",
        "exception" => {
          "message"   => "_message_",
          "backtrace" => ["_link_#:0"],
          "file"      => "unknown",
          "line"      => "unknown",
          "source"    => "unknown",
          "snippet"   => {"0" => "_link_"},
          "class"     => "Unknown"
        }
      )
      subject.instance_variable_set(:@result, result)
      subject.send(:failing_spec)
    end

  end

  describe "#log" do

    it "calls STDOUT.print" do
      STDOUT.should_receive(:print).with(%{---\nfoo: bar\n})
      subject.send(:log, "foo" => "bar")
    end
  end

end
