require "spec_helper"

describe Teaspoon::Drivers::SeleniumDriver do

  describe "#initialize" do

  end

  describe "#run_specs" do

    let(:runner) { double }

    before do
      @driver = double(quit: nil, navigate: @navigate = double(to: nil), execute_script: nil)
      Selenium::WebDriver.stub(:for).and_return(@driver)
      Selenium::WebDriver::Wait.stub(:new).and_return(@wait = double(until: nil))
    end

    it "loads firefox for the webdriver" do
      Selenium::WebDriver.should_receive(:for).with(:firefox)
      subject.run_specs(runner, "_url_")
    end

    it "navigates to the correct url" do
      @navigate.should_receive(:to).with("_url_")
      subject.run_specs(runner, "_url_")
    end

    it "ensures quit is called on the driver" do
      @driver.should_receive(:quit)
      subject.run_specs(runner, "_url_")
    end

    it "waits for the specs to complete, setting the interval, timeout and message" do
      Selenium::WebDriver::Wait.should_receive(:new).with(timeout: 180, interval: 0.01, message: "Timed out")
      subject.run_specs(runner, "_url_")
    end

    it "waits until it's done (checking Teaspoon.finished) and processes each line" do
      @wait.should_receive(:until) { |&b| @block = b }
      @driver.should_receive(:execute_script).with("return window.Teaspoon && window.Teaspoon.finished").and_return(true)
      @driver.should_receive(:execute_script).with("return window.Teaspoon && window.Teaspoon.getMessages() || []").and_return(["_line_"])
      runner.should_receive(:process).with("_line_\n")
      subject.run_specs(runner, "_url_")
      @block.call
    end

  end

end
