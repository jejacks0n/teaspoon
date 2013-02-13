require "spec_helper"
require "teabag/drivers/selenium_driver"

describe Teabag::Drivers::SeleniumDriver do

  describe "#run_specs" do

    before do
      @navigate = mock(to: nil)
      @driver = mock(quit: nil, navigate: @navigate, execute_script: nil)
      Selenium::WebDriver.stub(:for).and_return(@driver)
      @wait = mock(until: nil)
      Selenium::WebDriver::Wait.stub(:new).and_return(@wait)
    end

    it "instantiates the formatter" do
      runner = mock(failure_count: nil)
      Teabag::Runner.should_receive(:new).and_return(runner)
      subject.run_specs(:default, "_url_")
    end

    it "returns the number of failures from the runner" do
      runner = mock(failure_count: 42)
      Teabag::Runner.should_receive(:new).and_return(runner)
      expect(subject.run_specs(:default, "_url_")).to be(42)
    end

    it "loads firefox for the webdriver" do
      Selenium::WebDriver.should_receive(:for).with(:firefox)
      subject.run_specs(:default, "_url_")
    end

    it "navigates to the correct url" do
      @navigate.should_receive(:to).with("_url_")
      subject.run_specs(:default, "_url_")
    end

    it "ensures quit is called on the driver" do
      @driver.should_receive(:quit)
      subject.run_specs(:default, "_url_")
    end

    it "waits for the specs to complete, setting the interval, timeout and message" do
      Selenium::WebDriver::Wait.should_receive(:new).with(timeout: 180, interval: 0.01, message: "Timed out")
      subject.run_specs(:default, "_url_")
    end

    it "waits until it's done (checking Teabag.finished) and processes each line" do
      @block = nil
      @wait.should_receive(:until) { |&b| @block = b }
      @driver.should_receive(:execute_script).with("return window.Teabag && window.Teabag.finished").and_return(true)
      @driver.should_receive(:execute_script).with("return window.Teabag && window.Teabag.getMessages() || []").and_return(["_line_"])
      Teabag::Runner.any_instance.should_receive(:process).with("_line_\n")
      subject.run_specs(:default, "_url_")
      @block.call
    end

  end

end
