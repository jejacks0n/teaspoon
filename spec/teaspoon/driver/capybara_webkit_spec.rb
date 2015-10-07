require "spec_helper"

describe Teaspoon::Driver.fetch(:capybara_webkit) do
  let(:runner) { double }
  let(:document) { double(synchronize: nil) }
  let(:session) { instance_double(Capybara::Session, visit: nil, evaluate_script: nil, document: document) }
  let(:error) { Teaspoon::Driver::CapybaraWebkit::TeaspoonNotFinishedError }

  before do
    allow(Capybara::Session).to receive(:new).and_return(session)
  end

  describe "#run_specs" do
    it "navigates to the correct url" do
      expect(session).to receive(:visit).with("_url_")
      subject.run_specs(runner, "_url_")
    end

    it "waits for the specs to complete setting the timeout" do
      expect(document).to receive(:synchronize).with(180, errors: [error]) do |_timeout, _opts, &block|
        begin
          block.call
        rescue error
        end
      end
      subject.run_specs(runner, "_url_")
    end

    it "waits until it's done (checking Teaspoon.finished) and processes each line" do
      expect(document).to receive(:synchronize).with(180, errors: [error]).and_yield
      expect(session).to receive(:evaluate_script).with("window.Teaspoon && window.Teaspoon.finished").
        and_return(true)
      expect(session).to receive(:evaluate_script).with("window.Teaspoon && window.Teaspoon.getMessages()").
        and_return(["_line_"])
      expect(runner).to receive(:process).with("_line_\n")
      subject.run_specs(runner, "_url_")
    end
  end
end
