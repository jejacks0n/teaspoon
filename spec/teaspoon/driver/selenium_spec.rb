require "spec_helper"

describe Teaspoon::Driver.fetch(:selenium) do
  let(:runner) { double }
  let(:wait) { double(until: nil) }
  let(:driver) { double(quit: nil, navigate: @navigate = double(to: nil), execute_script: nil) }

  before do
    allow(Selenium::WebDriver).to receive(:for).and_return(driver)
    allow(Selenium::WebDriver::Wait).to receive(:new).and_return(wait)
  end

  describe "#initialize" do
    it "assigns @options" do
      subject = described_class.new(foo: "bar")
      expect(subject.instance_variable_get(:@options)).to eq(foo: "bar")
    end

    it "accepts a string for options" do
      subject = described_class.new('{"foo":"bar"}')
      expect(subject.instance_variable_get(:@options)).to eq("foo" => "bar")
    end

    it "raises an exception if the options aren't understood" do
      expect { described_class.new(true) }.to raise_error(
        Teaspoon::DriverOptionsError,
        "Malformed driver options: expected a valid hash or json string."
      )
    end

    it "raises an exception if the options aren't parseable" do
      expect { described_class.new("{foo:bar}") }.to raise_error(
        Teaspoon::DriverOptionsError,
        "Malformed driver options: expected a valid hash or json string."
      )
    end
  end

  describe "#run_specs" do
    it "loads firefox for the webdriver" do
      expect(Selenium::WebDriver).to receive(:for).with(:firefox, {})
      subject.run_specs(runner, "_url_")
    end

    it "navigates to the correct url" do
      expect(@navigate).to receive(:to).with("_url_")
      subject.run_specs(runner, "_url_")
    end

    it "ensures quit is called on the driver" do
      expect(driver).to receive(:quit)
      subject.run_specs(runner, "_url_")
    end

    it "waits for the specs to complete, setting the interval, timeout and message" do
      hash = HashWithIndifferentAccess.new(
        client_driver: :firefox,
        timeout: 180,
        interval: 0.01,
        message: "Timed out",
        selenium_options: {}
      )
      expect(Selenium::WebDriver::Wait).to receive(:new).with(hash)
      subject.run_specs(runner, "_url_")
    end

    it "waits until it's done (checking Teaspoon.finished) and processes each line" do
      expect(wait).to receive(:until) { |&b| @block = b }
      expect(driver).to receive(:execute_script).with("return window.Teaspoon && window.Teaspoon.finished").
        and_return(true)
      expect(driver).to receive(:execute_script).with("return window.Teaspoon && window.Teaspoon.getMessages() || []").
        and_return(["_line_"])
      expect(runner).to receive(:process).with("_line_\n")
      subject.run_specs(runner, "_url_")
      @block.call
    end
  end
end
