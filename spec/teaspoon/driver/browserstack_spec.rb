require "spec_helper"

describe Teaspoon::Driver.fetch(:browserstack) do
  let(:runner) { double }
  let(:wait) { double(until: nil) }
  let(:driver) { double(quit: nil, navigate: @navigate = double(to: nil), execute_script: nil, capabilities: {}) }

  before do
    allow(Selenium::WebDriver).to receive(:for).and_return(driver)
    allow(Selenium::WebDriver::Wait).to receive(:new).and_return(wait)
  end

  describe "#initialize" do
    it "assigns @options" do
      subject = described_class.new(capabilities: [{ foo: "bar" }])
      expect(subject.instance_variable_get(:@options)).to eq(capabilities: [{ foo: "bar" }])
    end

    it "raises an exception if options does not have a capabilities array" do
      expect { described_class.new('{"foo":"bar"}') }.to raise_error(
        Teaspoon::DriverOptionsError,
        "Malformed driver options: expected a valid capabilities array." \
        "Options must have a key 'capabilities' of type array."
      )
    end

    it "accepts a string for options" do
      subject = described_class.new('{"capabilities":[{"foo":"bar"}]}')
      expect(subject.instance_variable_get(:@options)).to eq(capabilities: [{ foo: "bar" }])
    end

    it "converts all the keys in each hash in capabilities array to symbols" do
      subject = described_class.new(capabilities: [{ "foo" => "bar" }, { "foo2" => "bar2" }])
      expect(subject.instance_variable_get(:@options)).to eq(capabilities: [{ foo: "bar" }, { foo2: "bar2" }])
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
    it "appends 'browserstack.local = true to all capabilities" do
      expect(Selenium::WebDriver).to receive(:for).with(
        :remote,
        url: "https://dummy_user:dummy_key@hub.browserstack.com/wd/hub",
        desired_capabilities: { foo: "bar", "browserstack.local" => true }
      )
      expect(Selenium::WebDriver).to receive(:for).with(
        :remote,
        url: "https://dummy_user:dummy_key@hub.browserstack.com/wd/hub",
        desired_capabilities: { foo2: "bar2", "browserstack.local" => true }
      )
      subject = described_class.new(capabilities: [{ "foo" => "bar" }, { "foo2" => "bar2" }],
                                    username: "dummy_user", access_key: "dummy_key")
      subject.run_specs(runner, "_url_")
    end

    it "accepts BrowserStack username and accesskey from options" do
      expect(Selenium::WebDriver).to receive(:for).with(
        :remote,
        url: "https://dummy_user:dummy_key@hub.browserstack.com/wd/hub",
        desired_capabilities: { foo: "bar", "browserstack.local" => true }
      )
      subject = described_class.new(capabilities: [{ "foo" => "bar" }],
                                    username: "dummy_user", access_key: "dummy_key")
      subject.run_specs(runner, "_url_")
    end

    it "accepts BrowserStack username and accesskey from environment" do
      allow(ENV).to receive(:[]).with("BROWSERSTACK_USERNAME").and_return("env_dummy_user")
      allow(ENV).to receive(:[]).with("BROWSERSTACK_ACCESS_KEY").and_return("env_dummy_key")

      expect(Selenium::WebDriver).to receive(:for).with(
        :remote,
        url: "https://env_dummy_user:env_dummy_key@hub.browserstack.com/wd/hub",
        desired_capabilities: { foo: "bar", "browserstack.local" => true })
      subject = described_class.new(capabilities: [{ "foo" => "bar" }])
      subject.run_specs(runner, "_url_")
    end

    it "navigates to the correct url" do
      expect(@navigate).to receive(:to).with("_url_")
      subject = described_class.new(capabilities: [{ "foo" => "bar" }])
      subject.run_specs(runner, "_url_")
    end

    it "ensures quit is called on the driver for every browser" do
      expect(driver).to receive(:quit).twice
      subject = described_class.new(capabilities: [{ "foo" => "bar" }, { "foo2" => "bar2" }])
      subject.run_specs(runner, "_url_")
    end

    it "waits for the specs to complete, setting the interval, timeout and message" do
      hash = HashWithIndifferentAccess.new(timeout: 180, interval: 0.01, message: "Timed out", capabilities: anything)
      expect(Selenium::WebDriver::Wait).to receive(:new).with(hash)
      subject = described_class.new(capabilities: [{ "foo" => "bar" }])
      subject.run_specs(runner, "_url_")
    end

    it "waits until it's done (checking Teaspoon.finished) and processes each line" do
      expect(wait).to receive(:until) { |&b| @block = b }
      expect(driver).to receive(:execute_script).with("return window.Teaspoon && window.Teaspoon.finished").
        and_return(true)
      expect(driver).to receive(:execute_script).with("return window.Teaspoon && window.Teaspoon.getMessages() || []").
        and_return(["_line_"])
      expect(runner).to receive(:process).with("_line_\n")
      subject = described_class.new(capabilities: [{ "foo" => "bar" }])
      subject.run_specs(runner, "_url_")
      @block.call
    end
  end
end
