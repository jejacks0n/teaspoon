require "socket"
require "timeout"
require "webrick"

module Teabag
  class Server

    def initialize
      @port = find_available_port
      Thin::Logging.silent = true if defined?(Thin)
    end

    def start
      STDOUT.print "Starting server...\n" unless Teabag.configuration.suppress_log
      @thread = Thread.new do
        server = Rack::Server.new(rack_options)
        server.start
      end
      wait_until_started
    rescue => e
      raise "Cannot start server: #{e.message}"
    end

    def wait_until_started
      Timeout.timeout(Teabag.configuration.server_timeout) { @thread.join(0.1) until responsive? }
    rescue Timeout::Error
      raise "Server failed to start. You may need to increase the timeout configuration."
    end

    def responsive?
      return false if @thread && @thread.join(0)
      TCPSocket.new("127.0.0.1", port).close
      return true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      return false
    end

    def url
      "http://127.0.0.1:#{port}"
    end

    def port
      @port
    end

    protected

    def rack_options
      {
        app: Rails.application,
        Port: port,
        environment: "test",
        AccessLog: [],
        Logger: WEBrick::Log::new(nil, 0)
      }
    end

    def find_available_port
      server = TCPServer.new("127.0.0.1", 0)
      server.addr[1]
    ensure
      server.close if server
    end
  end
end
