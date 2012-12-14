require "spec_helper"

describe Teabag::Result do

  let(:suite_name) { 'My Suite' }
  let(:json) do
    { "type"              => "spec",
      "suite"             => "_suite_name_",
      "spec"              => "_spec_name_",
      "status"            => "failed",
      "skipped"           => false,
      "link"              => "?grep=_spec_description_",
      "message"           => "_message_",
      "trace"             => "_trace_",
      "full_description"  => "_spec_description_" }
  end
  let(:result) { Teabag::Result.build_from_json(suite_name, json) }

  describe ".build_from_json" do

    describe "with a results object" do
      let(:json) do
        { "elapsed"  => 0.01,
          "failures" => 10,
          "pending"  => 1,
          "total"    => 25 }
      end

      it 'should assign a suite name from the first parameter' do
        expect(result.teabag_suite).to eq('My Suite')
      end

      it 'should assign a elapsed from the JSON hash' do
        expect(result.elapsed).to eq(0.01)
      end

      it 'should assign failures from the JSON hash' do
        expect(result.failures).to eq(10)
      end

      it 'should assign pending from the JSON hash' do
        expect(result.pending).to eq(1)
      end

      it 'should assign total from the JSON hash' do
        expect(result.total).to eq(25)
      end

    end

    describe "with a spec" do
      it 'should assign a suite name from the first parameter' do
        expect(result.teabag_suite).to eq('My Suite')
      end
      it 'should assign a type from the JSON hash' do
        expect(result.type).to eq('spec')
      end
      it 'should assign a suite from the JSON hash' do
        expect(result.suite).to eq('_suite_name_')
      end
      it 'should assign a spec from the JSON hash' do
        expect(result.spec).to eq('_spec_name_')
      end
      it 'should assign a full description from the JSON hash' do
        expect(result.full_description).to eq('_spec_description_')
      end
      it 'should assign a status from the JSON hash' do
        expect(result.status).to eq('failed')
      end
      it 'should assign skipped from the JSON hash' do
        expect(result.skipped).to be_false
      end
      it 'should assign a link from the JSON hash' do
        expect(result.link).to eq('?grep=_spec_description_')
      end
      it 'should assign a message from the JSON hash' do
        expect(result.message).to eq('_message_')
      end
      it 'should assign a trace from the JSON hash' do
        expect(result.trace).to eq('_trace_')
      end
    end
  end

end
