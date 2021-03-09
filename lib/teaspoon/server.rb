require "socket"
require "timeout"
# no longer ship with ruby 3, but is it required?
# require "webrick"

module Teaspoon
  class Server
    attr_accessor :port, :host

    def initialize
      @host = Teaspoon.configuration.server_host || "127.0.0.1"
      @port = Teaspoon.configuration.server_port || find_available_port
    end

    def start
      return if responsive?

      thread = Thread.new do
        disable_logging
        server = Rack::Server.new(rack_options)
        server.start
      end
      wait_until_started(thread)
    rescue => e
      raise Teaspoon::ServerError.new(desc: e.message)
    end

    def responsive?
      TCPSocket.new(host, port).close
      true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      false
    end

    def url
      "http://#{host}:#{port}"
    end

    protected

      def wait_until_started(thread)
        Timeout.timeout(Teaspoon.configuration.server_timeout.to_i) { thread.join(0.1) until responsive? }
      rescue Timeout::Error
        raise Timeout::Error.new("consider increasing the timeout with `config.server_timeout`")
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
          Host: host,
          Port: port,
          environment: "test",
          AccessLog: [],
          Logger: Rails.logger,
          server: Teaspoon.configuration.server,
          Silent: true
        }
      end

      def find_available_port
        server = TCPServer.new(host, 0)
        server.addr[1]
      ensure
        server.close if server
      end
  end
end
