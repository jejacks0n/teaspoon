require "spec_helper"
require "teabag/server"
require "net/http"

describe Teabag::Server do

  subject { Teabag::Server.new }

  before do
    Teabag::Server.any_instance.stub(find_available_port: 31337)
    STDOUT.stub(:print)
  end

  describe "#start" do

    before do
      subject.stub(wait_until_started: nil)
    end

    it "spawns a thread" do
      Thread.should_receive(:new)
      subject.start
    end

    it "starts a rack server" do
      STDOUT.should_receive(:print).with("Starting the Teabag server...\n")
      server = mock(start: nil)
      Thread.stub(:new) { |&b| @block = b }

      Rack::Server.should_receive(:new).and_return(server)
      server.should_receive(:start)

      subject.start
      @block.call
    end

    it "rescues errors" do
      Thread.should_receive(:new).and_raise("OMG!")
      expect{ subject.start }.to raise_error("Cannot start server: OMG!")
    end

    describe "when the server configuration option is set" do
      before do
        Teabag.configuration.server = :cgi
      end

      after do
        Teabag.configuration.server = nil
      end

      it "creates a Rack::Server with the correct setting" do
        Rack::Server.should_receive(:new) do |options|
          options.should include(:server => :cgi)
        end
        subject.start
      end
    end
  end

  describe "#wait_until_started" do

    it "uses Timeout" do
      Timeout.should_receive(:timeout).with(20)
      subject.wait_until_started
    end

    it "handles Timeout::Error" do
      Timeout.should_receive(:timeout).and_raise(Timeout::Error)
      expect{ subject.wait_until_started }.to raise_error("Server failed to start. You may need to increase the timeout configuration.")
    end

  end

  describe "#responsive?" do

    before do
      subject.instance_variable_set(:@thread, mock(join: nil))
    end

    it "checks a local port to see if a server is running" do
      socket = mock(close: nil)
      TCPSocket.should_receive(:new).with("127.0.0.1", 31337).and_return(socket)
      socket.should_receive(:close)
      subject.wait_until_started
    end

  end

  describe "#url" do

    it "returns a url for the server that includes the port" do
      expect(subject.url).to eq("http://127.0.0.1:31337")
    end

  end

  describe "#port" do

    it "returns the port the server is on" do
      expect(subject.port).to eq(31337)
    end

  end

  describe "integration" do

    it "really starts a server" do
      Teabag.configuration.stub(:suites).and_return "foo" => proc{ |suite| }
      subject.start
      response = Net::HTTP.get_response(URI.parse("#{subject.url}/teabag/foo"))
      expect(response.code).to eq("200")
    end

  end

end
