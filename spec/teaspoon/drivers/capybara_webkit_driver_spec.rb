require "spec_helper"

describe Teaspoon::Drivers::CapybaraWebkitDriver do

  describe "#run_specs" do

    let(:runner) { double }
    let(:document) { double }
    let(:session) { instance_double(Capybara::Session) }

    before do
      allow(Capybara).to receive(:current_driver=).with(:webkit)
      expect(Capybara::Session).to receive(:new).and_return session
      allow(session).to receive(:visit)
      allow(session).to receive(:document).and_return(document)
      allow(session).to receive(:evaluate_script)
      allow(document).to receive(:synchronize).and_yield
    end

    specify do
      def behavior(message);yield;end

      behavior "loads webkit for the webdriver" do
        expect(Capybara).to receive(:current_driver=).with(:webkit)
        subject.run_specs(runner, "_url_")
      end

      behavior "navigates to the correct url" do
        expect(session).to receive(:visit).with("_url_")
        subject.run_specs(runner, "_url_")
      end

      behavior "waits for the specs to complete setting the timeout" do
        expect(document).to receive(:synchronize).with(180).and_yield
        subject.run_specs(runner, "_url_")
      end

      behavior "waits until it's done (checking Teaspoon.finished) and processes each line" do
        expect(document).to receive(:synchronize).with(180).and_yield
        expect(session).to receive(:evaluate_script).with("window.Teaspoon && window.Teaspoon.finished").and_return(true)
        expect(session).to receive(:evaluate_script).with("window.Teaspoon && window.Teaspoon.getMessages()").and_return(["_line_"])
        expect(runner).to receive(:process).with("_line_\n")
        subject.run_specs(runner, "_url_")
      end
    end

  end

end
