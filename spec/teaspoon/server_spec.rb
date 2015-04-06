require "spec_helper"
require "teaspoon/server"
require "net/http"

describe Teaspoon::Server do
  describe "#start" do
    let(:server) { double(start: nil) }

    before do
      allow(Thread).to receive(:new) do |&b|
        @block = b
        "_thread_"
      end
      allow(subject).to receive(:wait_until_started).and_return(nil)
    end

    it "spawns a thread" do
      expect(Thread).to receive(:new)
      subject.start
    end

    it "starts a rack server" do
      expect(Rack::Server).to receive(:new).and_return(server)
      expect(server).to receive(:start)

      subject.start
      @block.call
    end

    it "waits until the server is started" do
      expect(Thread).to receive(:new)
      expect(subject).to receive(:wait_until_started).with("_thread_")
      subject.start
    end

    it "rescues errors" do
      expect(Thread).to receive(:new).and_raise("OMG!")
      expect { subject.start }.to raise_error(
        Teaspoon::ServerError,
        "Unable to start teaspoon server; OMG!."
      )
    end

    it "creates a Rack::Server with the correct setting" do
      expected_opts = {
        app: Rails.application,
        Port: subject.port,
        environment: "test",
        AccessLog: [],
        Logger: Rails.logger,
        server: Teaspoon.configuration.server
      }
      expect(Rack::Server).to receive(:new).with(expected_opts).and_return(server)

      subject.start
      @block.call
    end

    it "raises an exception if the timeout fails" do
      expect(subject).to receive(:wait_until_started).and_call_original
      expect(Timeout).to receive(:timeout).with(Teaspoon.configuration.server_timeout.to_i).
        and_raise(Timeout::Error)
      expect { subject.start }.to raise_error(
        Teaspoon::ServerError,
        "Unable to start teaspoon server; consider increasing the timeout with `config.server_timeout`."
      )
    end
  end

  describe "#responsive?" do
    let(:socket) { double(close: nil) }

    it "checks a local port to see if a server is running" do
      subject.port = 31337
      expect(TCPSocket).to receive(:new).with("127.0.0.1", 31337).and_return(socket)
      expect(socket).to receive(:close)
      subject.responsive?
    end
  end

  describe "#url" do
    it "returns a url for the server that includes the port" do
      subject.port = 31337
      expect(subject.url).to eq("http://127.0.0.1:31337")
    end
  end

  describe "integration" do
    before do
      suite_config = proc { |c| c.javascripts = ["foo"] }
      allow(Teaspoon.configuration).to receive(:suite_configs).and_return("foo" => { block: suite_config })
      allow(Teaspoon.configuration).to receive(:suppress_log).and_return(true)
    end

    it "really starts a server" do
      subject.start
      response = Net::HTTP.get_response(URI.parse("#{subject.url}/teaspoon/foo"))
      expect(response.code).to eq("200")
    end
  end
end
