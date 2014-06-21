require "spec_helper"

describe Teaspoon::Drivers::SeleniumDriver do

  describe "#initialize" do

    it "assigns @options" do
      subject = Teaspoon::Drivers::SeleniumDriver.new(foo: "bar")
      expect(subject.instance_variable_get(:@options)).to eq(foo: "bar")
    end

    it "accepts a string for options" do
      subject = Teaspoon::Drivers::SeleniumDriver.new('{"foo":"bar"}')
      expect(subject.instance_variable_get(:@options)).to eq("foo" => "bar")
    end

    it "raises a Teaspoon::UnknownDriverOptions exception if the options aren't understood" do
      expect { Teaspoon::Drivers::SeleniumDriver.new(true) }.to raise_error(Teaspoon::UnknownDriverOptions)
    end

    it "raises a Teaspoon::UnknownDriverOptions exception if the options aren't parseable" do
      expect { Teaspoon::Drivers::SeleniumDriver.new("{foo:bar}") }.to raise_error(Teaspoon::UnknownDriverOptions)
    end

  end

  describe "#run_specs" do

    let(:runner) { double }

    before do
      @driver = double(quit: nil, navigate: @navigate = double(to: nil), execute_script: nil)
      allow(Selenium::WebDriver).to receive(:for).and_return(@driver)
      allow(Selenium::WebDriver::Wait).to receive(:new).and_return(@wait = double(until: nil))
    end

    it "loads firefox for the webdriver" do
      expect(Selenium::WebDriver).to receive(:for).with(:firefox)
      subject.run_specs(runner, "_url_")
    end

    it "navigates to the correct url" do
      expect(@navigate).to receive(:to).with("_url_")
      subject.run_specs(runner, "_url_")
    end

    it "ensures quit is called on the driver" do
      expect(@driver).to receive(:quit)
      subject.run_specs(runner, "_url_")
    end

    it "waits for the specs to complete, setting the interval, timeout and message" do
      expect(Selenium::WebDriver::Wait).to receive(:new).with(HashWithIndifferentAccess.new(client_driver: :firefox, timeout: 180, interval: 0.01, message: "Timed out"))
      subject.run_specs(runner, "_url_")
    end

    it "waits until it's done (checking Teaspoon.finished) and processes each line" do
      expect(@wait).to receive(:until) { |&b| @block = b }
      expect(@driver).to receive(:execute_script).with("return window.Teaspoon && window.Teaspoon.finished").and_return(true)
      expect(@driver).to receive(:execute_script).with("return window.Teaspoon && window.Teaspoon.getMessages() || []").and_return(["_line_"])
      expect(runner).to receive(:process).with("_line_\n")
      subject.run_specs(runner, "_url_")
      @block.call
    end

  end

end
