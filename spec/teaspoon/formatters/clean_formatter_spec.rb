require "spec_helper"

describe Teaspoon::Formatters::CleanFormatter do

  let(:passing_spec) { double(passing?: true) }
  let(:pending_spec) { double(passing?: false, pending?: true, description: "_description_") }
  let(:failing_spec) { double(passing?: false, pending?: false, description: "_description_", message: "_message_", link: "_link_") }

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#result" do

    let(:result) { double(elapsed: 3.1337, coverage: nil) }

    before do
      subject.run_count = 666
    end

    describe "with failures" do

      before do
        subject.failures << failing_spec
      end

      it "logs the failures but not the failure commands" do
        subject.result(result)
        expect(@log).to eq("\n\nFailures:\n\n  1) _description_\n\e[31m     Failure/Error: _message_\n\e[0m\nFinished in 3.1337 seconds\n\e[31m666 examples, 1 failure\e[0m\n")
      end

    end

  end

end
