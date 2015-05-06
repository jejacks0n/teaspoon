require "spec_helper"

describe Teaspoon::Engine do
  subject { described_class }

  it "has been isolated with a name" do
    expect(subject.isolated?).to be(true)
    expect(subject.railtie_name).to eql("teaspoon")
  end

  it "defaults the root path" do
    # this has to add spec/dummy as we set it manually
    expect(Teaspoon.configuration.root.join("spec/dummy").to_s).to eq(Rails.root.to_s)
  end

  it "adds asset paths from configuration" do
    root = Teaspoon.configuration.root
    expect(Rails.application.config.assets.paths).to include(root.join("spec/javascripts/stylesheets").to_s)
    expect(Rails.application.config.assets.paths).to include(root.join("spec/javascripts").to_s)
  end

  describe Teaspoon::Engine::ExceptionHandling do
    subject { described_class }

    before do
      @orig_debug = Rails.application.config.assets.debug
      @orig_show_exceptions = Rails.application.config.action_dispatch.show_exceptions
    end

    after do
      Rails.application.config.assets.debug = @orig_debug
      Rails.application.config.action_dispatch.show_exceptions = @orig_show_exceptions
    end

    describe ".add_rails_handling" do
      before do
        allow(subject).to receive(:render_exceptions_with_javascript)
      end

      it "sets config.assets.debug to false" do
        subject.add_rails_handling
        expect(Rails.application.config.assets.debug).to be_falsey
      end

      it "sets config.action_dispatch.show_exceptions to true" do
        subject.add_rails_handling
        expect(Rails.application.config.action_dispatch.show_exceptions).to be_truthy
      end

      it "calls #render_exceptions_with_javascript" do
        expect(subject).to receive(:render_exceptions_with_javascript)
        subject.add_rails_handling
      end
    end

    describe "ActionDispatch::DebugExceptions#render_exception mixin" do
      before do
        subject.add_rails_handling
      end

      let(:middleware) { ActionDispatch::DebugExceptions.new(app) }
      let(:app) { double(:app) }
      let(:env) { double(:env, "[]" => []) }

      it "responds with a javascript tag that raises the error" do
        response = middleware.send(:render_exception, env, Exception.new("_message_"))
        expect(response).to eq(
          [
            200,
            { "Content-Type" => "text/html;", "Content-Length" => "54" },
            ["<script>throw Error(\"Exception: _message_\\n\")</script>"]
          ]
        )
      end
    end
  end
end
