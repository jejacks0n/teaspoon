require "spec_helper"
require "teaspoon/drivers/phantomjs_driver"

describe Teaspoon::Drivers::PhantomjsDriver do

  describe "#run_specs" do

    context "with phantomjs" do

      before do
        subject.stub(:run)
      end

      it "instantiates the runner" do
        runner = double(failure_count: nil)
        Teaspoon::Runner.should_receive(:new).and_return(runner)
        subject.run_specs(:default, "_url_")
      end

      it "calls run and logs the results of each line using the formatter" do
        args = [Teaspoon::Engine.root.join("lib/teaspoon/drivers/phantomjs/runner.js").to_s, "_url_", Teaspoon.configuration.timeout.to_s]
        Teaspoon::Runner.any_instance.should_receive(:process).with("_line_")
        @block = nil
        subject.should_receive(:run).with(*args) { |&b| @block = b }
        subject.run_specs(:default, "_url_")
        @block.call("_line_")
      end

    end

    context "without phantomjs" do

      it "tells you that it couldn't find phantomjs and exits" do
        subject.should_receive(:which).and_return(nil)
        STDOUT.should_receive(:print).with("Could not find PhantomJS. Install phantomjs or try the phantomjs gem.")
        expect { subject.run_specs(:default, "_url_") }.to raise_error SystemExit
      end

    end

  end

end
