require "spec_helper"
require "teaspoon/drivers/phantomjs_driver"

describe Teaspoon::Drivers::PhantomjsDriver do

  describe "#run_specs" do

    before do
      Phantomjs.stub(:run)
    end

    it "instantiates the formatter" do
      runner = double(failure_count: nil)
      Teaspoon::Runner.should_receive(:new).and_return(runner)
      subject.run_specs(:default, "_url_")
    end

    it "calls phantomjs.run and logs the results of each line using the formatter" do
      args = [Teaspoon::Engine.root.join("lib/teaspoon/drivers/phantomjs/runner.coffee").to_s, "_url_"]
      Teaspoon::Runner.any_instance.should_receive(:process).with("_line_")
      @block = nil
      Phantomjs.should_receive(:run).with(*args) { |&b| @block = b }
      subject.run_specs(:default, "_url_")
      @block.call("_line_")
    end

  end

end
