require "spec_helper"

describe Teaspoon::ExceptionHandling do

  subject { Teaspoon::ExceptionHandling }

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
      subject.stub(:render_exceptions_with_javascript)
    end

    it "sets config.assets.debug to false" do
      subject.add_rails_handling
      expect(Rails.application.config.assets.debug).to be_false
    end

    it "sets config.action_dispatch.show_exceptions to true" do
      subject.add_rails_handling
      expect(Rails.application.config.action_dispatch.show_exceptions).to be_true
    end

    it "calls #render_exceptions_with_javascript" do
      subject.should_receive(:render_exceptions_with_javascript)
      subject.add_rails_handling
    end

  end

  describe "ActionDispatch::DebugExceptions#render_exception mixin" do

    before do
      subject.add_rails_handling
    end

    let(:middleware) { ActionDispatch::DebugExceptions.new(app, nil) }
    let(:app) { double(:app) }
    let(:env) { double(:env, "[]" => []) }

    it "responds with a javascript tag that raises the error" do
      response = middleware.send(:render_exception, env, Exception.new("_message_"))
      expect(response).to eq([200, {"Content-Type"=>"text/html;", "Content-Length"=>"54"}, ["<script>throw Error(\"Exception: _message_\\n\")</script>"]])
    end

  end

end
