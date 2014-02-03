require "socket"
require "timeout"
require "webrick"

module Teaspoon
  class Server

    def initialize
      @port = find_available_port
      if defined?(Thin)
        if Teaspoon.configuration.suppress_log
          Thin::Logging.silent = true
        else
          Thin::Logging.trace = false
        end
      end
    end

    def start
      STDOUT.print "Starting the Teaspoon server...\n" unless Teaspoon.configuration.suppress_log
      @thread = Thread.new do
        server = Rack::Server.new(rack_options)
        server.start
      end
      wait_until_started
    rescue => e
      raise "Cannot start server: #{e.message}"
    end

    def wait_until_started
      Timeout.timeout(Teaspoon.configuration.server_timeout.to_i) { @thread.join(0.1) until responsive? }
    rescue Timeout::Error
      raise "Server failed to start. You may need to increase the timeout configuration."
    end

    def responsive?
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
        Logger: Rails.logger,
        server: Teaspoon.configuration.server
      }
    end

    def find_available_port
      return Teaspoon.configuration.server_port if Teaspoon.configuration.server_port
      server = TCPServer.new("127.0.0.1", 0)
      server.addr[1]
    ensure
      server.close if server
    end
  end
end
