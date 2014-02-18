require "spec_helper"
require "teaspoon/result"

describe Teaspoon::Result do

  subject { Teaspoon::Result.build_from_json(json) }
  let(:suite_name) { 'My Suite' }
  let(:json) {{
    "type"     => "spec",
    "suite"    => "_suite_name_",
    "label"    => "_spec_name_",
    "status"   => "failed",
    "skipped"  => false,
    "link"     => "?grep=_spec_description_",
    "message"  => "_message_",
    "trace"    => "_trace_",
    "coverage" => "_coverage_",
  }}

  describe ".build_from_json" do

    describe "with a results object" do

      let(:json) {{
        "elapsed"  => 0.01,
        "failures" => 10,
        "pending"  => 1,
        "total"    => 25
      }}

      it "assigns from the JSON hash" do
        expect(subject.elapsed).to eq(0.01)
        expect(subject.total).to eq(25)
      end

    end

    describe "with a spec" do

      it "assigns from the JSON hash" do
        expect(subject.type).to eq('spec')
        expect(subject.suite).to eq('_suite_name_')
        expect(subject.label).to eq('_spec_name_')
        expect(subject.description).to eq('_suite_name_ _spec_name_')
        expect(subject.status).to eq('failed')
        expect(subject.skipped).to be_false
        expect(subject.link).to eq('?grep=_spec_description_')
        expect(subject.message).to eq('_message_')
        expect(subject.trace).to eq('_trace_')
        expect(subject.coverage).to eq('_coverage_')
      end

    end

  end

  describe "#failing?" do

    it "returns a boolean based on status" do
      subject.status = "foo"
      expect(subject.failing?).to be_true
      subject.status = "bar"
      expect(subject.failing?).to be_true
      subject.status = "passed"
      expect(subject.failing?).to be_false
      subject.status = "pending"
      expect(subject.failing?).to be_false
    end

  end

  describe "#passing?" do

    it "returns a boolean based on status" do
      subject.status = "passed"
      expect(subject.passing?).to be_true
      subject.status = "foo"
      expect(subject.passing?).to be_false
    end

  end

  describe "#pending?" do

    it "returns a boolean based on status" do
      subject.status = "pending"
      expect(subject.pending?).to be_true
      subject.status = "foo"
      expect(subject.pending?).to be_false
    end

  end

end
