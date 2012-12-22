require "spec_helper"
require "teabag/result"

describe Teabag::Result do

  let(:suite_name) { 'My Suite' }
  let(:json) do
    { "type"              => "spec",
      "suite"             => "_suite_name_",
      "label"             => "_spec_name_",
      "status"            => "failed",
      "skipped"           => false,
      "link"              => "?grep=_spec_description_",
      "message"           => "_message_",
      "trace"             => "_trace_" }
  end
  let(:result) { Teabag::Result.build_from_json(json) }

  describe ".build_from_json" do

    describe "with a results object" do

      let(:json) do
        { "elapsed"  => 0.01,
          "failures" => 10,
          "pending"  => 1,
          "total"    => 25 }
      end

      it "assigns from the JSON hash" do
        expect(result.elapsed).to eq(0.01)
        expect(result.total).to eq(25)
      end

    end

    describe "with a spec" do

      it "assigns from the JSON hash" do
        expect(result.type).to eq('spec')
        expect(result.suite).to eq('_suite_name_')
        expect(result.label).to eq('_spec_name_')
        expect(result.description).to eq('_suite_name_ _spec_name_')
        expect(result.status).to eq('failed')
        expect(result.skipped).to be_false
        expect(result.link).to eq('?grep=_spec_description_')
        expect(result.message).to eq('_message_')
        expect(result.trace).to eq('_trace_')
      end

    end

  end

end
