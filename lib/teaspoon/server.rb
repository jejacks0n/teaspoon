require "socket"
require "timeout"
require "webrick"

module Teaspoon
  class Server

    attr_accessor :port

    def initialize
      @port = Teaspoon.configuration.server_port || find_available_port
    end

    def start
      thread = Thread.new do
        disable_logging
        server = Rack::Server.new(rack_options)
        server.start
      end
      wait_until_started(thread)
    rescue => e
      raise Teaspoon::ServerException, "Cannot start server: #{e.message}"
    end

    def responsive?
      TCPSocket.new("127.0.0.1", port).close
      true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      false
    end

    def url
      "http://127.0.0.1:#{port}"
    end

    protected

    def wait_until_started(thread)
      Timeout.timeout(Teaspoon.configuration.server_timeout.to_i) { thread.join(0.1) until responsive? }
    rescue Timeout::Error
      raise Teaspoon::ServerException, "Server failed to start. You may need to increase the timeout configuration."
    end

    def disable_logging
      return unless defined?(Thin)
      if Teaspoon.configuration.suppress_log
        Thin::Logging.silent = true
      else
        Thin::Logging.trace = false
      end
    end

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
      server = TCPServer.new("127.0.0.1", 0)
      server.addr[1]
    ensure
      server.close if server
    end
  end
end
